#!/bin/bash -xve

# This is a utility script that I run in a cron job, locally.  It syncs the
# live production worker type definitions with a local git repository. This
# allows me to crudely track changes to worker type definitions.  I don't
# publish the repository, because it contains secrets, so if you also want to
# track history, you could run this too. My local repository is located at
# ~/worker_type_definitions (hard coded in this script).

# My cron job looks like this:
#  00,05,10,15,20,25,30,35,40,45,50,55 * * * * /Users/pmoore/git/mozilla/sync-secrets.sh > ~/sync-secrets.log 2>&1

# The sourced file exports TASKCLUSTER_CLIENT_ID, TASKCLUSTER_ACCESS_TOKEN, TASKCLUSTER_ROOT_URL and PATH.
source ~/sync-secrets.env

cd ~
rm -rf secrets/*
date
if ! download-secrets; then
  say -v Daniel "Something went wrong updating secrets"
  cd ~/secrets
  git clean -fdx
  git reset --hard
  exit 64
fi
date
cd secrets
if test $(git status --porcelain | wc -l) != 0; then
  say -v Daniel "Secret changes have been found"
  git add .
  git -c "commit.gpgsign=false" commit -m "$(git status --porcelain)"
fi

say -v Daniel "secrets sunk!"
