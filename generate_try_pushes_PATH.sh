#!/bin/bash

cd ~/hg/mozilla-central

for ((x=1; x<=36; x++)); do
  P="$(cat ~/x | sed "${x}d" | tr '\n' ';' | sed 's/;$//')"
  M="$(cat ~/x | sed -n "${x}p")"
  cat ~/firefox_win32_opt.yml | sed 's/^\( *PATH: "\).*\(".*\)/\1'"${P//\\/\\\\}"'\2/' > ~/hg/mozilla-central/testing/taskcluster/tasks/builds/firefox_win32_opt.yml
  hg commit -m "Removed $M from PATH. try: -b o -p win32 -u none -t none"
  hg log -p -r .
  hg push -f try -r .
  hg strip --keep -r .
done
