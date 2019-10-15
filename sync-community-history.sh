#!/bin/bash -xve

# This is a utility script that I run in a cron job, locally. It syncs the live
# community taskcluster entities with the community-history git repository.
# This allows us to crudely track changes to taskcluster entity definitions
# (AWS worker type definitions, clients, hooks, roles, hashed secrets).

# My cron job looks like this:
#  00,05,10,15,20,25,30,35,40,45,50,55 * * * * /Users/pmoore/git/mozilla/sync-community-history.sh > ~/sync-community-history.log 2>&1

# Note, the 'say' command is part of macOS. I prefer my computer to audibly say
# what it is doing, and if there is a problem, so that I do not need to
# routinely check logs. I just hear about problems (literally) if they occur.

# This sourced file exports TASKCLUSTER_CLIENT_ID, TASKCLUSTER_ACCESS_TOKEN,
# TASKCLUSTER_ROOT_URL and PATH. My client has `secrets:get:*` (required).
source ~/sync-community-history.env

export GOPATH=~/community-history-gopath
rm -rf "${GOPATH}"
go get -u github.com/taskcluster/mozilla-history
git clone git@github.com:taskcluster/community-history.git
cd community-history
if ! "${GOPATH}/bin/mozilla-history"; then
  say -v Daniel "Something went wrong running the mozilla-history command."
  exit 64
fi
if test $(git status --porcelain | wc -l) != 0; then
  say -v Daniel "Taskcluster entity changes have been found."
  git add .
  # Unescape unicode characters from git status output:
  # \342\201\204 is octal escape sequence for fraction slash  (U+2044)  ⁄  ->  /
  # \342\230\205 is octal escape sequence for black star      (U+2605)  ★  ->  *
  git -c "commit.gpgsign=false" commit -m "$(git status --porcelain | sed 's/\\342\\201\\204/\//g' | sed 's/\\342\\230\\205/*/g' | sed 's/"//g')"
  git push origin master
  say -v Daniel "Pushed changes"
fi

# say -v Daniel "Sunk!"
