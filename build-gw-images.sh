#!/usr/bin/env bash

BRANCH='main'

function retry {
  set +e
  local n=0
  # 2^10 seconds (17m 4s) is enough seconds to wait
  local max=10
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
        return 67
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
export AZURE_IMAGE_RESOURCE_GROUP=rg-tc-eng-images

retry az login

for rg in $(az group list --query "[?starts_with(name, 'imageset-')].name" -o tsv); do
  echo "Deleting old resource group ${rg}..."
  az group delete --name $rg --yes --no-wait
done

retry gcloud components update -q
retry gcloud auth login

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

cd tc-admin
python3.11 -m venv tc-admin-venv
source tc-admin-venv/bin/activate
pip3 install pytest
pip3 install --upgrade pip

git clone git@github.com:taskcluster/community-tc-config.git
cd community-tc-config

if [ "${BRANCH}" != 'main' ]; then
  git checkout "${BRANCH}"
  # in case branch was created prior to the latest image builds, pull in all commits from main
  # to ensure we don't revert to old amis from the time the branch was created!
  git pull origin main
  cat imagesets/imageset.sh > x
  cat x \
    | sed 's/exit 70/# exit 70/' \
    | sed 's/exit 69/# exit 69/' \
    | sed 's/return 70/# return 70/' \
    | sed 's/return 69/# return 69/' \
    | sed 's%+HEAD:refs/heads/main%+HEAD:refs/heads/'"${BRANCH}"'%' \
    | sed 's/git -c pull\.rebase/# &/' \
    | sed 's/pass git -c pull\.rebase/# &/' \
    > imagesets/imageset.sh
  rm x
fi

pip3 install -e .
which tc-admin
export TASKCLUSTER_ACCESS_TOKEN="$(pass ls community-tc/root | head -1)"

eval $(imagesets/signin-aws.sh)

if [ "${BRANCH}" == 'main' ]; then
  echo "Updating EC2 instance types..."
  misc/update-ec2-instance-types.sh
  git add 'config/ec2-instance-type-offerings'
  git commit -m "Ran script misc/update-ec2-instance-types.sh" || true

  echo "Updating Azure VM sizes..."
  misc/update-azure-vm-sizes.sh
  git add 'config/azure-vm-size-offerings'
  git commit -m "Ran script misc/update-azure-vm-sizes.sh" || true

  echo "Updating GCE machine types..."
  misc/update-gce-machine-types.sh
  git add 'config/gce-machine-type-offerings.json'
  git commit -m "Ran script misc/update-gce-machine-types.sh" || true

  retry git push origin "${BRANCH}"
  retry tc-admin apply
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

git commit -m "chore: bump to TC ${VERSION}" || true
retry git push origin "${BRANCH}"

cd ..



#######################################################################################
######## Comment out image sets / macOS workers that don't need to be updated! ########
#######################################################################################


##################################
###### Update macOS workers ######
##################################
#
# Remeber to vnc as administrator onto macs before running this script, to avoid ssh connection problems!

for IP in 207.254.55.60 207.254.55.167; do
  pass "macstadium/generic-worker-ci/${IP}" | tail -1 | ssh "administrator@${IP}" sudo -S "bash" -c /var/root/update.sh
done

########## Azure Windows ##########
imagesets/imageset.sh azure update generic-worker-win2022 &
imagesets/imageset.sh azure update generic-worker-win2022-staging &
imagesets/imageset.sh azure update generic-worker-win2022-gpu &
imagesets/imageset.sh azure update generic-worker-win11-24h2-staging &

########## Non-Azure Windows ##########
imagesets/imageset.sh aws update generic-worker-win2022 &

########## Ubuntu ##########
imagesets/imageset.sh google update generic-worker-ubuntu-24-04 &
imagesets/imageset.sh aws update generic-worker-ubuntu-24-04 &
imagesets/imageset.sh google update generic-worker-ubuntu-24-04-arm64 &
imagesets/imageset.sh google update generic-worker-ubuntu-24-04-staging &
imagesets/imageset.sh aws update generic-worker-ubuntu-24-04-staging &

########## Docker Worker ##########
imagesets/imageset.sh google update docker-worker &
imagesets/imageset.sh aws update docker-worker &

wait

retry tc-admin apply

echo
echo "Deleting preparation directory: ${PREP_DIR}..."
echo
cd
rm -rf "${PREP_DIR}"
echo "All done!"
