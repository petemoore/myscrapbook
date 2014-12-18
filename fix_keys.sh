#!/bin/bash

ssh buildduty@aws-manager1.srv.releng.scl3.mozilla.com cat slaves.json.pete | sed 's/"name"/"name"\n/g' | sed -n 's/^: "\([^"]*\).*/\1/p' | sort -u | grep spot | while read machine
do
    python aws_manage_instances.py status ${machine}
done | sed -n 's/^     IP: //p' | while read IP
do
    ssh cltbld@${IP} '[ ! -f .ssh/ffxbld_rsa ] && hostname || echo ok' < /dev/null
done
