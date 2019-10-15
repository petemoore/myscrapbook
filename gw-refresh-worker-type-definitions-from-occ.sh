#!/bin/bash -xve

function git_no_gpg {
    git -c "commit.gpgsign=false" "${@}"
}

# export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/go/bin"
source ~/gw-refresh-worker-type-definitions-from-occ.env
TMP_GW_CHECKOUT="$(mktemp -d -t refresh-gw-worker-types.XXXXXXXXXX)"
cd "${TMP_GW_CHECKOUT}"
git clone git@github.com:taskcluster/generic-worker
cd generic-worker/worker_types
./generate_occ_userdata.sh
git_no_gpg add .
if ! git_no_gpg commit -m "Refreshed gecko worker type definitions from latest OCC manifests"; then
  # say -v Daniel "No OCC changes"
  exit 64
fi
if ! git_no_gpg push origin master; then
  say -v Daniel "Problem updating OCC manifests. Pete, what is going on?"
  exit 65
fi
say -v Daniel "Updated OCC manifests"
cd ~
rm -rf "${TMP_GW_CHECKOUT}"
exit 0
