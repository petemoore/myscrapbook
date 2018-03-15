#!/bin/bash -exv

NEW_VERSION="${1}"

if [ -z "${NEW_VERSION}" ]; then
  echo "Must specify version, e.g. '${0}' 10.4.1" >&2
  exit 64
fi

CHECKOUT="$(mktemp -d -t opencloudconfig.XXXXXXXXXX)"
cd "${CHECKOUT}"

for ARCH in 386 amd64
do
  curl -L "https://github.com/taskcluster/generic-worker/releases/download/v${NEW_VERSION}/generic-worker-windows-${ARCH}.exe" > "generic-worker-windows-${ARCH}-v${NEW_VERSION}.exe"
  tooltool.py add --visibility internal "generic-worker-windows-${ARCH}-v${NEW_VERSION}.exe"
done
cat manifest.tt
tooltool.py upload --authentication-file=~/tooltool-upload --message "Bug 1399401: Upgrade *STAGING* worker types to use generic-worker ${NEW_VERSION}"

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
git commit -m "Bug 1399401 - Rolled out generic-worker ${NEW_VERSION} to *STAGING*

This change does _not_ affect any production workers. Commit made with:

    ./upgrade-gw-betas-cu.sh ${NEW_VERSION}

See https://github.com/petemoore/myscrapbook/blob/master/upgrade-gw-betas-cu.sh" -m "${DEPLOY}"
git push
open 'https://github.com/mozilla-releng/OpenCloudConfig/commits/master'
cd ~/git/OpenCloudConfig
git pull
echo rm -rf "${CHECKOUT}"
