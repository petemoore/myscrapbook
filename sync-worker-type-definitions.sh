#!/bin/bash -xv
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

# This sets TASKCLUSTER_CLIENT_ID, TASKCLUSTER_ACCESS_TOKEN and PATH.
# I personally use this client, fwiw:
# https://auth.taskcluster.net/v1/clients/mozilla-auth0%2Fad%7CMozilla-LDAP%7Cpmoore%2Ffetch-worker-type-definitions
source ~/sync-worker-type-definitions.env

# say -v Daniel "let's sync those definitions"

cd ~/worker_type_definitions
git_no_tty clean -fdx
git_no_tty reset --hard
cd ..
# See https://github.com/taskcluster/generic-worker/blob/master/worker_types/all-worker-types/main.go
all-worker-types
cd worker_type_definitions
git_no_tty add .
git_no_tty commit -m "$(git status --porcelain)"

rm "${GPG_NO_TTY}"

# say -v Daniel "definitions have all been sunk, sir!"
