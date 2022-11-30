#!/usr/bin/env bash

# git commit this script will test livelog docker image for
GIT_COMMIT='8ce2ef31cd6df83f14aa492618f0f3ac156d0094'

# version to pull the (dockerflow) version.json file from (any old release will do)
OLD_LIVELOG_TAG=v44.23.4

set -eu
set -o pipefail

# put everything in a temp directory
rm -rf test-livelog
mkdir test-livelog
cd test-livelog

# need a hostname in taskcluster-worker.net domain - add it if it doesn't exist
grep -Fq pete.taskcluster-worker.net /etc/hosts || echo '127.0.0.1 pete.taskcluster-worker.net' | sudo tee -a /etc/hosts >/dev/null

git clone https://github.com/taskcluster/taskcluster
git -C taskcluster reset --hard "${GIT_COMMIT}"

# extract Dockerfile from script
cat taskcluster/infrastructure/tooling/src/build/tasks/livelog.js | sed -n '/ AS certs/,/ENTRYPOINT/p' | sed -e "s/^ *'//" -e "s/',$//" > Dockerfile

# build livelog linux/amd64 version
(cd taskcluster/tools/livelog; GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o ../../../livelog)

# extract version.json from previous docker image
mkdir oldimage
cd oldimage
docker create --name=livelog-container-1 "taskcluster/livelog:${OLD_LIVELOG_TAG}"
docker export livelog-container-1 | tar x
docker rm livelog-container-1
cd ..
cp oldimage/app/version.json .

# build new livelog docker image
docker build -t=taskcluster/livelog:local-build -f ./Dockerfile .

# get secrets needed for testing ssl, as we do in production
pass ls docker-worker/yaml/community-tc.yaml | sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' | sed 's/^ *//' > myssl.crt
pass ls docker-worker/yaml/community-tc.yaml | sed -n '/-----BEGIN RSA PRIVATE KEY-----/,/-----END RSA PRIVATE KEY-----/p' | sed 's/^ *//' > myssl.key

# start livelog inside docker image
docker run -v "$(pwd):/keys" -p 127.0.0.1:9110:34253 -p 127.0.0.1:9111:23536 -e ACCESS_TOKEN='secretpuppy' -e DEBUG='*' -e LIVELOG_PUT_PORT='34253' -e LIVELOG_GET_PORT='23536' -e SERVER_CRT_FILE=/keys/myssl.crt -e SERVER_KEY_FILE=/keys/myssl.key taskcluster/livelog:local-build /livelog &
docker_run_pid=$!
echo
echo "**************************************************************************"
echo "After you quit this script, you should execute the following:"
echo "$ kill -9 ${docker_run_pid}"
echo "**************************************************************************"
echo
# give container/livelog service a few seconds to start up
sleep 5

# log some fake log lines to livelog container
# curl will exit when docker run process is killed later, so no need to track pid from curl command
(for ((i=1; i<=500; i++)); do echo "Log line $i"; sleep 1; done) | curl -v -T - http://localhost:9110/log &

# wait a bit before connecting
sleep 5

# tail logs via livelog service running in docker container
curl -v https://pete.taskcluster-worker.net:9111/log/secretpuppy
