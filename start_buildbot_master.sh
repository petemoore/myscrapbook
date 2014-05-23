#!/bin/bash

cd ~/fabric
source bin/activate
# python ~/git/tools/buildfarm/maintenance/manage_masters.py -f ~/git/tools/buildfarm/mobile/devices.json  -j15 -H all show_revision
# python ~/git/tools/buildfarm/maintenance/manage_masters.py -H buildbot-master10.build.mtv1.mozilla.com start
python ~/git/tools/buildfarm/maintenance/manage_masters.py -f ~/git/tools/buildfarm/maintenance/production-masters.json -H bm22-tests1-tegra restart
deactivate
