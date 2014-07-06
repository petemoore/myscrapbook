#!/bin/bash
while true
do
    ssh -R 13425:localhost:22 vcs2vcs@vcssync1.srv.releng.usw2.mozilla.com 'rsync -av -e "ssh -oStrictHostKeyChecking=no -p 13425 pmoore@localhost ssh" /opt/vcs2vcs/build/ gd4:/home/pmoore/vcs_sync/build/'
done
