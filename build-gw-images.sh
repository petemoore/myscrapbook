#!/usr/bin/env bash

BRANCH='main'

function retry {
  set +e
  local n=0
  local max=20
  while true; do
    "$@" && break || {
      if [[ $n -lt $max ]]; then
        ((n++))
        echo "Command failed" >&2
        sleep_time=$((2 ** n))
        echo "Sleeping $sleep_time seconds..." >&2
        sleep $sleep_time
        echo "Attempt $n/$max:" >&2
      else
        echo "Failed after $n attempts." >&2
        exit 67
      fi
    }
  done
  set -e
}

set -eu
set -o pipefail

export TASKCLUSTER_CLIENT_ID='static/taskcluster/root'
export TASKCLUSTER_ROOT_URL='https://community-tc.services.mozilla.com'
unset TASKCLUSTER_CERTIFICATE

export GCP_PROJECT=community-tc-workers

PREP_DIR="$(mktemp -t deploy-worker-pools.XXXXXXXXXX -d)"
cd "${PREP_DIR}"

echo
echo "Preparing in directory ${PREP_DIR}..."
echo

VERSION="$(retry curl https://api.github.com/repos/taskcluster/taskcluster/releases/latest 2>/dev/null | jq -r .tag_name)"
if [ -z "${VERSION}" ]; then
  echo "Cannot retrieve taskcluster version" >&2
  exit 64
fi

mkdir tc-admin
pip3 install --upgrade pip

cd tc-admin
python3 -m venv tc-admin-venv
source tc-admin-venv/bin/activate
pip3 install pytest
pip3 install --upgrade pip

git clone git@github.com:taskcluster/community-tc-config.git
cd community-tc-config

if [ "${BRANCH}" != 'main' ]; then
  git checkout "${BRANCH}"
  cat imagesets/imageset.sh > x
  cat x \
    | sed 's/exit 70/# exit 70/' \
    | sed 's/exit 69/# exit 69/' \
    | sed 's%+HEAD:refs/heads/main%+HEAD:refs/heads/'"${BRANCH}"'%' \
    | sed 's/git -c pull\.rebase/# &/' \
    | sed 's/pass git -c pull\.rebase/# &/' \
    > imagesets/imageset.sh
  rm x
fi

pip3 install -e .
which tc-admin
retry gcloud auth login
retry pass git pull
export TASKCLUSTER_ACCESS_TOKEN="$(pass ls community-tc/root | head -1)"

eval $(imagesets/signin-aws.sh)

if [ "${BRANCH}" == 'main' ]; then
  echo "Updating EC2 instance types..."
  misc/update-ec2-instance-types.sh
  git add 'config/ec2-instance-type-offerings'
  git commit --no-gpg-sign -m "Ran script misc/update-ec2-instance-types.sh" || true

  echo "Updating GCE machine types..."
  misc/update-gce-machine-types.sh
  git add 'config/gce-machine-type-offerings.json'
  git commit --no-gpg-sign -m "Ran script misc/update-gce-machine-types.sh" || true

  retry git push origin "${BRANCH}"
  retry tc-admin apply --without-secrets
fi

cd imagesets
git ls-files | grep -F 'bootstrap.' | while read file; do
  cat "${file}" > "${file}.bak"
  cat "${file}.bak" | sed 's/^ *setenv TASKCLUSTER_VERSION .*/setenv TASKCLUSTER_VERSION '"${VERSION}"'/' \
    | sed 's/^ *TASKCLUSTER_VERSION=.*/TASKCLUSTER_VERSION='"'${VERSION}'"'/' \
    | sed 's/^ *\$TASKCLUSTER_VERSION *=.*/$TASKCLUSTER_VERSION = "'"${VERSION}"'"/' \
    > "${file}"
  rm "${file}.bak"
  git add "${file}"
done

git commit --no-gpg-sign -m "chore: bump to TC ${VERSION}" || true
retry git push origin "${BRANCH}"

cd ..



#########################################################################
######## Comment out worker pools that don't need to be updated! ########
#########################################################################


########## Ubuntu ##########
imagesets/imageset.sh google update generic-worker-ubuntu-22-04
retry tc-admin apply --without-secrets
imagesets/imageset.sh aws update generic-worker-ubuntu-22-04
retry tc-admin apply --without-secrets
imagesets/imageset.sh google update generic-worker-ubuntu-22-04-arm64
retry tc-admin apply --without-secrets

########## Windows ##########
imagesets/imageset.sh aws update generic-worker-win2016-amd
retry tc-admin apply --without-secrets
imagesets/imageset.sh aws update generic-worker-win2022
retry tc-admin apply --without-secrets

########## Staging ##########
imagesets/imageset.sh google update generic-worker-ubuntu-22-04-staging
retry tc-admin apply --without-secrets
imagesets/imageset.sh aws update generic-worker-ubuntu-22-04-staging
retry tc-admin apply --without-secrets

echo
echo "Deleting preparation directory: ${PREP_DIR}..."
echo
cd
rm -rf "${PREP_DIR}"
echo "All done!"
