#!/bin/bash

cd ~/fabric
source bin/activate
# python ~/git/tools/buildfarm/maintenance/manage_foopies.py -f ~/git/tools/buildfarm/mobile/devices.json  -j15 -H all watcher_version
python ~/git/tools/buildfarm/maintenance/manage_foopies.py -f ~/git/tools/buildfarm/mobile/devices.json  -j15 -H foopy115 watcher_version
deactivate
