#!/bin/bash

cd ~/hg/mozilla-central

for ((x=13; x<=48; x++)); do
  cat ~/firefox_win32_opt.yml | sed "${x}s/^ /#/" > ~/hg/mozilla-central/testing/taskcluster/tasks/builds/firefox_win32_opt.yml
  hg commit -m "Commented out line ${x}. try: -b o -p win32 -u none -t none"
  hg log -p -r .
  hg push -f try -r .
  hg strip --keep -r .
done
