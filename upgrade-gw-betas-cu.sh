#!/bin/bash -exv

NEW_VERSION="${1}"

if [ -z "${NEW_VERSION}" ]; then
  echo "Must specify version, e.g. '${0}' 10.4.1" >&2
  exit 64
fi

cd "$(dirname "${0}")"
THIS_SCRIPT_DIR="$(pwd)"

CHECKOUT="$(mktemp -d -t opencloudconfig.XXXXXXXXXX)"
cd "${CHECKOUT}"

for ARCH in 386 amd64
do
  echo "Waiting for generic-worker ${NEW_VERSION} ($ARCH) to be available on github..."
  DOWNLOAD_URL="https://github.com/taskcluster/generic-worker/releases/download/v${NEW_VERSION}/generic-worker-windows-${ARCH}.exe"
  LOCAL_FILE="generic-worker-windows-${ARCH}-v${NEW_VERSION}.exe"
  while ! curl -s -I "${DOWNLOAD_URL}" | head -1 | grep -q '302 Found'; do
    sleep 3
    echo -n '.'
  done
  echo
  curl -L "${DOWNLOAD_URL}" > "${LOCAL_FILE}"
  tooltool.py add --visibility internal "${LOCAL_FILE}"
done
cat manifest.tt
which tooltool.py
tooltool.py upload -v --authentication-file="$(echo ~/tooltool-upload)" --message "Bug 1399401: Upgrade *STAGING* worker types to use generic-worker ${NEW_VERSION}"

git clone git@github.com:mozilla-releng/OpenCloudConfig.git
cd OpenCloudConfig/userdata/Manifest
for MANIFEST in *-b.json *-cu.json *-beta.json; do
  cat "${MANIFEST}" > "${MANIFEST}.bak"
  cat "${MANIFEST}.bak" | sed "s_\\(generic-worker/releases/download/v\\)[^/]*\\(/generic-worker-windows-\\)_\\1${NEW_VERSION}\\2_" | sed "s_\\(\"generic-worker \\)[^\"]*\\(\"\\)_\\1${NEW_VERSION}\\2_" > "${MANIFEST}"
  cat "${MANIFEST}" > "${MANIFEST}.bak"
  THIS_ARCH="$(cat "${MANIFEST}" | sed -n 's/.*\/generic-worker-windows-\(.*\)\.exe.*/\1/p' | sort -u)"
  if [ "${ARCH}" != "386" ] && [ "${ARCH}" != "amd64" ]; then
    echo "NOOOOOOO - cannot recognise ARCH" >&2
    exit 67
  fi
  SHA512="$(jq --arg filename "generic-worker-windows-${THIS_ARCH}-v${NEW_VERSION}.exe" '.[] | select(.filename == $filename) .digest' ../../../manifest.tt | sed 's/"//g')"
  if [ ${#SHA512} != 128 ]; then
    echo "NOOOOOOO - SHA512 is not 128 bytes: '${SHA512}'" >&2
    exit 68
  fi
  jq --arg sha512 "${SHA512}" --arg componentName GenericWorkerDownload '(.Components[] | select(.ComponentName == $componentName) | .sha512) |= $sha512' "${MANIFEST}.bak" > "${MANIFEST}"
  rm "${MANIFEST}.bak"
done
DEPLOY="deploy: $(echo *-b.json *-cu.json *-beta.json | sed 's/\.json//g')"
git add .
git commit -m "Testing generic-worker ${NEW_VERSION} on *STAGING*

This change does _not_ affect any production workers. Commit made with:

    ./upgrade-gw-betas-cu.sh ${NEW_VERSION}

See https://github.com/petemoore/myscrapbook/blob/master/upgrade-gw-betas-cu.sh" -m "${DEPLOY}"
OCC_COMMIT="$(git rev-parse HEAD)"
git push
open 'https://github.com/mozilla-releng/OpenCloudConfig/commits/master'
cd ~/hg/mozilla-central
hg up -C
hg purge

# wait for OCC deployment to complete
go run "${THIS_SCRIPT_DIR}/waitforOCC.go" "${OCC_COMMIT}"

hg pull -u -r default
curl -L 'https://bug1400012.bmoattachments.org/attachment.cgi?id=8948627' | hg import -
hg push -f ssh://hg.mozilla.org/try/ -r .
open 'https://treeherder.mozilla.org/#/jobs?repo=try'

cd ~/git/OpenCloudConfig
git pull
echo rm -rf "${CHECKOUT}"
