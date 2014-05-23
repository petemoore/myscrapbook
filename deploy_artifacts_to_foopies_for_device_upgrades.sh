#!/bin/bash

cd "$(dirname "${0}")"

for foopy in foopy113 foopy116 foopy119 foopy122 foopy124 foopy126
do
    echo "$foopy"
#   scp install_all_watchers.sh "cltbld@${foopy}:."
#   scp Watcher.1.16.apk "cltbld@${foopy}:/builds/tools/sut_tools/Watcher.1.16.apk"
#   scp install_watcher.py "cltbld@${foopy}:/builds/tools/sut_tools/install_watcher.py"
#   scp all_watcher_versions.sh "cltbld@${foopy}:."
#   scp watcher_version.py "cltbld@${foopy}:/builds/tools/sut_tools/watcher_version.py"
    ssh "root@${foopy}" "sed -i 's/^# //' /etc/cron.d/puppetcheck.cron; cat /etc/cron.d/puppetcheck.cron"
    ssh "root@${foopy}" "sed -i 's/^# //' /etc/cron.d/foopy; cat /etc/cron.d/foopy"
done
