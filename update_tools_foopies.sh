#!/bin/bash -exv

cd ~/fabric
source bin/activate
python ~/git/tools/buildfarm/maintenance/manage_foopies.py -f ~/git/tools/buildfarm/mobile/devices.json  -j15 -H all show_revision
python ~/git/tools/buildfarm/maintenance/manage_foopies.py -f ~/git/tools/buildfarm/mobile/devices.json  -j15 -H all update
python ~/git/tools/buildfarm/maintenance/manage_foopies.py -f ~/git/tools/buildfarm/mobile/devices.json  -j15 -H all show_revision
deactivate
