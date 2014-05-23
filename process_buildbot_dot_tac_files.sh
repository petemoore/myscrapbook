#!/bin/bash

cd ~/fabric
source bin/activate
# python ~/git/tools/buildfarm/maintenance/manage_foopies.py -f ~/git/tools/buildfarm/mobile/devices.json  -j15 -H all what_master > ~/devices
deactivate

cd
cat devices | grep dev-master01 | sed 's/^.......//' | sed 's/ .*//' | sort -u > staging_devices

while read device
do
    line="$(grep -n "${device}" ~/git/tools/buildfarm/mobile/devices.json | sed 's/:.*//')"
    foopy="$(sed -n -e "${line},\$s/foopy/&/p" ~/git/tools/buildfarm/mobile/devices.json | head -1)"
    echo "${foopy}"
done < staging_devices | sed -n 's/.*"\(foopy[0-9][0-9]*\)".*/\1/p' | sort -u > staging_foopies

while read foopy
do
    ssh "cltbld@${foopy}" 'ls -1d /builds/{tegra,panda}-* | sed "s/.*\///"' </dev/null 2>/dev/null
done < staging_foopies | sort -u > all_devices_on_staging_foopies

echo "Devices on staging foopies, that are not staging devices"
echo "========================================================"
echo
diff staging_devices all_devices_on_staging_foopies
