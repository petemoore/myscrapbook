#!/bin/bash -xve

# This is a utility script that I run in a cron job, locally.  It syncs the
# live production worker type definitions with a local git repository. This
# allows me to crudely track changes to worker type definitions.  I don't
# publish the repository, because it contains secrets, so if you also want to
# track history, you could run this too. My local repository is located at
# ~/worker_type_definitions (hard coded in this script).

# My cron job looks like this:
#  00,05,10,15,20,25,30,35,40,45,50,55 * * * * /Users/pmoore/git/mozilla/sync-worker-type-definitions.sh > ~/sync-worker-type-definitions.log 2>&1

# The sourced file exports TASKCLUSTER_CLIENT_ID, TASKCLUSTER_ACCESS_TOKEN and PATH.
# I personally use this client, fwiw:
# https://auth.taskcluster.net/v1/clients/mozilla-auth0%2Fad%7CMozilla-LDAP%7Cpmoore%2Ffetch-worker-type-definitions
source ~/sync-worker-type-definitions.env

# say -v Daniel "syncing"

cd ~
rm aws-provisioner-v1-worker-type-definitions/*
# See https://github.com/taskcluster/generic-worker/blob/master/aws/cmd/aws-worker-types/main.go
date
if ! download-aws-worker-type-definitions; then
  say -v Daniel "Something went wrong updating worker types"
  cd ~/aws-provisioner-v1-worker-type-definitions
  git clean -fdx
  git reset --hard
  exit 64
fi
date
cd aws-provisioner-v1-worker-type-definitions
if test $(git status --porcelain | wc -l) != 0; then
  say -v Daniel "Worker type changes have been found"
  git add .
  git -c "commit.gpgsign=false" commit -m "$(git status --porcelain)"
fi

say -v Daniel "sunk!"
