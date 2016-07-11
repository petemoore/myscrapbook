#!/bin/bash

## Example usage
## =============
##
##     $ worker_ip.sh i-8c95ca48
##     52.35.77.6

aws ec2 describe-instances --region us-east-1 --instance-id "${1}" --query 'Reservations[*].Instances[*].NetworkInterfaces[*].Association.PublicIp' --output text 2>/dev/null
aws ec2 describe-instances --region us-west-1 --instance-id "${1}" --query 'Reservations[*].Instances[*].NetworkInterfaces[*].Association.PublicIp' --output text 2>/dev/null
aws ec2 describe-instances --region us-west-2 --instance-id "${1}" --query 'Reservations[*].Instances[*].NetworkInterfaces[*].Association.PublicIp' --output text 2>/dev/null
