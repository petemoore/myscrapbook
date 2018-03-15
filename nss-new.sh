#!/bin/bash -xve

cd "$(dirname "${0}")"
SCRIPT_DIR="$(pwd)"

CHECKOUT="$(mktemp -d -t nss-new.XXXXXXXXXX)"
cd "${CHECKOUT}"
git clone git@github.com:taskcluster/generic-worker.git
NEW_VERSION="$(cat generic-worker/worker_types/nss-win2012r2-new/userdata | sed -n 's_.*https://github\.com/taskcluster/generic-worker/releases/download/v\(.*\)/generic-worker-windows-amd64\.exe.*_\1_p')"
VALID_FORMAT='^[1-9][0-9]*\.\(0\|[1-9][0-9]*\)\.\(0\|[1-9]\)\([0-9]*alpha[1-9][0-9]*\|[0-9]*\)$'

if ! echo "${NEW_VERSION}" | grep -q "${VALID_FORMAT}"; then
  echo "Release version '${NEW_VERSION}' not allowed" >&2
  exit 65
fi

./generic-worker/worker_types/worker_type.sh nss-win2012r2-new update

hg clone https://hg.mozilla.org/projects/nss
cd nss
cat "${SCRIPT_DIR}/nss-new.patch" | patch -p1 -i -
hg commit -m "Testing generic-worker ${NEW_VERSION} on nss-win2012r2-new worker type; try: -p win32,win64 -t none -u all"
hg push -f ssh://hg.mozilla.org/projects/nss-try -r .
open 'https://treeherder.mozilla.org/#/jobs?repo=nss-try'
cd "${SCRIPT_DIR}"

rm -rf "${CHECKOUT}"
