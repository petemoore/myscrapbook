#!/bin/bash

## Example usage
## =============
##
##     $ worker_ip.sh i-8c95ca48
##     52.35.77.6

aws ec2 describe-instances --instance-id "${1}" --query 'Reservations[*].Instances[*].NetworkInterfaces[*].Association.PublicIp' --output text
