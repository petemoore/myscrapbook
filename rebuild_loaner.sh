#!/bin/bash

ssh buildduty@aws-manager1 '
    source /builds/aws_manager/bin/activate
    python /builds/aws_manager/cloud-tools/scripts/aws_manage_instances.py terminate dev-linux64-ec2-pmoore
    cd /builds/aws_manager
    python cloud-tools/scripts/aws_create_instance.py -c cloud-tools/configs/dev-linux64 -r us-east-1 -s aws-releng --loaned-to pmoore@mozilla.com --bug 1048971 -k secrets/aws-secrets.json --ssh-key /home/buildduty/.ssh/aws-ssh-key -i cloud-tools/instance_data/us-east-1.instance_data_dev.json dev-linux64-ec2-pmoore
'
