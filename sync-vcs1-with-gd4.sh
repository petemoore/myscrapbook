#!/bin/bash
while true
do
    ssh -R 12344:localhost:22 vcs2vcs@vcssync1.srv.releng.usw2.mozilla.com 'rsync -av -e "ssh -p 12344 pmoore@localhost ssh" /opt/vcs2vcs/build/ gd4:/home/pmoore/vcs_sync/build/'
done
