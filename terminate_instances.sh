#!/bin/bash
aws --region us-west-1 ec2 terminate-instances --instance-ids "${@}"
aws --region us-west-2 ec2 terminate-instances --instance-ids "${@}"
aws --region us-east-1 ec2 terminate-instances --instance-ids "${@}"
