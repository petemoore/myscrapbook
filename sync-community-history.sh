#!/bin/bash -xve

# This is a utility script that I run in a cron job, locally. It syncs the live
# community taskcluster entities with the community-history git repository.
# This allows us to crudely track changes to taskcluster entity definitions
# (clients, hooks, roles, worker pools).

# My cron job looks like this:
#  02,07,12,17,22,27,32,37,42,47,52,57 * * * * /Users/pmoore/git/mozilla/sync-community-history.sh > ~/sync-community-history.log 2>&1

# Note, the 'say' command is part of macOS. I prefer my computer to audibly say
# what it is doing, and if there is a problem, so that I do not need to
# routinely check logs. I just hear about problems (literally) if they occur.

export TASKCLUSTER_ROOT_URL='https://community-tc.services.mozilla.com'
unset TASKCLUSTER_CLIENT_ID TASKCLUSTER_ACCESS_TOKEN TASKCLUSTER_CERTIFICATE
export GOPATH=~/community-history-gopath
export PATH="${GOPATH}/bin:/Users/pmoore/.cargo/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/go/bin:/usr/local/MacGPG2/bin:/opt/X11/bin:/Users/pmoore/bin::/Users/pmoore/git/mozilla:/usr/local/opt/apache-maven-3.3.3/bin:/usr/local/Cellar/gnupg/2.0.30_3/bin:/Users/pmoore/gcc-arm-none-eabi-7-2018-q2-update/bin:/Users/pmoore/git/arcanist/bin"

rm -rf "${GOPATH}"
mkdir "${GOPATH}"
cd "${GOPATH}"
go get -u github.com/taskcluster/mozilla-history
git clone git@github.com:taskcluster/community-history.git
cd community-history
if ! "${GOPATH}/bin/mozilla-history"; then
  say -v Daniel "Something went wrong running mozilla-history for the taskcluster community project."
  exit 64
fi
if test $(git status --porcelain | wc -l) != 0; then
  say -v Daniel "Taskcluster entity changes have been found in community project."
  git add .
  # Unescape unicode characters from git status output:
  # \342\201\204 is octal escape sequence for fraction slash  (U+2044)  ⁄  ->  /
  # \342\230\205 is octal escape sequence for black star      (U+2605)  ★  ->  *
  git -c "commit.gpgsign=false" commit -m "$(git status --porcelain | sed 's/\\342\\201\\204/\//g' | sed 's/\\342\\230\\205/*/g' | sed 's/"//g')"
  git push origin master
  say -v Daniel "Pushed taskcluster community changes"
fi
