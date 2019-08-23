#!/bin/bash -xve

GPG_NO_TTY="$(mktemp -t gpg-no-tty.XXXXXXXXXX)"
{
  echo '#!/bin/bash'
  echo 'gpg --no-tty "${@}"'
  echo 'exit $?'
} >> "${GPG_NO_TTY}"
chmod u+x "${GPG_NO_TTY}"

function git_no_tty {
    git -c "gpg.program=${GPG_NO_TTY}" "${@}"
}

# export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/go/bin"
source ~/gw-refresh-worker-type-definitions-from-occ.env
TMP_GW_CHECKOUT="$(mktemp -d -t refresh-gw-worker-types.XXXXXXXXXX)"
cd "${TMP_GW_CHECKOUT}"
git clone git@github.com:taskcluster/generic-worker
generic-worker/worker_types/generate_occ_userdata.sh
cd generic-worker/worker_types
git_no_tty add .
git_no_tty commit -m "Refreshed gecko worker type definitions from latest OCC manifests"
git_no_tty push origin master
say -v Daniel "Updated OCC manifests"
cd ~
rm -rf "${TMP_GW_CHECKOUT}"
