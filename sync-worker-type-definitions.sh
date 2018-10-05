#!/bin/bash -xve

# This is a utility script that I run in a cron job, locally.  It syncs the
# live production worker type definitions with a local git repository. This
# allows me to crudely track changes to worker type definitions.  I don't
# publish the repository, because it contains secrets, so if you also want to
# track history, you could run this too. My local repository is located at
# ~/worker_type_definitions (hard coded in this script).

# My cron job looks like this:
#  00,05,10,15,20,25,30,35,40,45,50,55 * * * * /Users/pmoore/git/mozilla/sync-worker-type-definitions.sh > ~/sync-worker-type-definitions.log 2>&1

# This muckery is to prevent gpg asking for a passphrase when making git commits
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

# The sourced file exports TASKCLUSTER_CLIENT_ID, TASKCLUSTER_ACCESS_TOKEN and PATH.
# I personally use this client, fwiw:
# https://auth.taskcluster.net/v1/clients/mozilla-auth0%2Fad%7CMozilla-LDAP%7Cpmoore%2Ffetch-worker-type-definitions
source ~/sync-worker-type-definitions.env

# say -v Daniel "syncing"

cd ~/aws-provisioner-v1-worker-type-definitions
git_no_tty clean -fdx
git_no_tty reset --hard
cd ..
# See https://github.com/taskcluster/generic-worker/blob/master/aws/cmd/aws-worker-types/main.go
date
if ! aws-worker-types; then
  say -v Daniel "Something went wrong updating worker types"
  exit 64
fi
date
cd aws-provisioner-v1-worker-type-definitions
if test $(git_no_tty status --porcelain | wc -l) != 0; then
  say -v Daniel "Worker type changes have been found"
  git_no_tty add .
  git_no_tty commit -m "$(git status --porcelain)"
fi
rm "${GPG_NO_TTY}"

say -v Daniel "sunk!"
