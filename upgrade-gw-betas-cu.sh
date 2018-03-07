#!/bin/bash

NEW_VERSION="${1}"

if [ -z "${NEW_VERSION}" ]; then
  echo "Must specify version, e.g. '${0}' 10.4.1" >&2
  exit 64
fi

CHECKOUT="$(mktemp -d -t opencloudconfig.XXXXXXXXXX)"
cd "${CHECKOUT}"
git clone git@github.com:mozilla-releng/OpenCloudConfig.git
cd OpenCloudConfig/userdata/Manifest
for MANIFEST in *-b.json *-cu.json *-beta.json; do
  cat "${MANIFEST}" > "${MANIFEST}.bak"
  cat "${MANIFEST}.bak" | sed "s_\\(generic-worker/releases/download/v\\)[^/]*\\(/generic-worker-windows-\\)_\\1${NEW_VERSION}\\2_" | sed "s_\\(\"generic-worker \\)[^\"]*\\(\"\\)_\\1${NEW_VERSION}\\2_" > "${MANIFEST}"
  rm "${MANIFEST}.bak"
done
DEPLOY="deploy: $(echo *-b.json *-cu.json *-beta.json | sed 's/\.json//g')"
git add .
git commit -m "Bug 1399401 - Rolled out generic-worker ${NEW_VERSION} to *STAGING* (not production)" -m "${DEPLOY}"
git push
open 'https://github.com/mozilla-releng/OpenCloudConfig/commits/master'
cd ~/git/OpenCloudConfig
git pull
rm -rf "${CHECKOUT}"
