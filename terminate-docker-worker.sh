#!/bin/bash -e

if [ -z "${1}" ]; then
  echo "Please specify a docker-worker release, e.g. v201902281053" >&2
  exit 64
fi

curl -L "https://github.com/taskcluster/docker-worker/releases/download/${1}/docker-worker-amis.json" | sed -n 's/^    "//p' | sed 's/": "/ /' | sed 's/".*//' | while read region ami; do aws ec2 --region "${region}" describe-instances --query 'Reservations[*].Instances[*].InstanceId' --output text --filters "Name=image-id,Values=${ami}" | xargs aws ec2 --region "${region}" terminate-instances --instance-ids; done
