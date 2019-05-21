#!/bin/bash -xve

# This is a utility script that I run in a cron job, locally. It syncs the live
# production taskcluster entities with the mozilla-history git repository.
# This allows us to crudely track changes to taskcluster entity definitions
# (AWS worker type definitions, clients, hooks, roles, hashed secrets).

# My cron job looks like this:
#  00,05,10,15,20,25,30,35,40,45,50,55 * * * * /Users/pmoore/git/mozilla/sync-mozilla-history.sh > ~/sync-mozilla-history.log 2>&1

# This sourced file exports TASKCLUSTER_CLIENT_ID, TASKCLUSTER_ACCESS_TOKEN,
# TASKCLUSTER_ROOT_URL and PATH. My client has `secrets:get:*` (required).
source ~/sync-mozilla-history.env

# say -v Daniel "syncing"

export GOPATH=~/mozilla-history-gopath
rm -rf "${GOPATH}"
go get -u github.com/taskcluster/mozilla-history
cd "${GOPATH}/src/github.com/taskcluster/mozilla-history"
date
if ! mozilla-history; then
  say -v Daniel "Something went wrong updating worker types"
  exit 64
fi
date
if test $(git status --porcelain | wc -l) != 0; then
  say -v Daniel "Worker type changes have been found"
  git add .
  git -c "commit.gpgsign=false" commit -m "$(git status --porcelain)"
  git push origin master
fi

say -v Daniel "sunk!"
