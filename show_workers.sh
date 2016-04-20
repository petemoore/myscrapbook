#!/bin/bash

aws ec2 describe-instances --filters Name=key-name,Values=pmoore-oregan-us-west-2 --query 'Reservations[*].Instances[*].{WORKER_TYPE:Tags[*].Value,PUBLIC_IP:NetworkInterfaces[*].Association.PublicIp,INSTANCE_ID:InstanceId}' --output text | while read INSTANCE_ID
do
  read x PUBLIC_IP
  read x WORKER_TYPE
  PASSWORD="$(aws ec2 get-password-data --instance-id "${INSTANCE_ID}" --priv-launch-key ~/.ssh/pmoore-oregan-us-west-2.pem --output text --query PasswordData)"
  echo "${WORKER_TYPE}"
  echo "${WORKER_TYPE//?/=}"
  echo "  Base ${INSTANCE_ID}:"
  echo "    ssh Administrator@${PUBLIC_IP} (password: '${PASSWORD}')"
  echo "  ------------------"
  aws ec2 describe-instances --filters "Name=tag-value,Values=${WORKER_TYPE}" "Name=tag-key,Values=Name" --query 'Reservations[*].Instances[*].{PUBLIC_IP:NetworkInterfaces[*].Association.PublicIp,INSTANCE_ID:InstanceId}' --output text | while read INST
  do
    read x IP
    echo "  Worker ${INST}:"
    echo "    ssh Administrator@${IP} (password: '${PASSWORD}')"
  done
done
