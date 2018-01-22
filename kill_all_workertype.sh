#!/bin/bash

workerType="${1}"

if [ -z "${workerType}" ]; then
  echo "Supply a worker type, e.g. ${0} deepspeech-worker" >&2
  exit 64
fi

for region in us-{east,west}-{1,2} ca-central-1 eu-central-1 eu-west-{1,2,3} ap-{north,south}east-{1,2} ap-south-1 sa-east-1; do
  echo "Looking for ${workerType} workers in ${region}..."
  aws --region "${region}" ec2 describe-instances --filters "Name=tag:Name,Values=${workerType}" --query 'Reservations[*].Instances[*].InstanceId' --output text | while read instanceId; do
    echo "Killing ${instanceId} in region ${region}..."; aws --region "${region}" ec2 terminate-instances --instance-ids "${instanceId}"
  done
done
