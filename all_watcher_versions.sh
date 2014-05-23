#!/bin/bash

cd /builds/tools/sut_tools
shopt -s nullglob
ls -1d /builds/{tegra,panda}-* | sed 's/.*\///' | while read device
do
    results="$(mktemp -t results.XXXXXXXXXX)"
    ./watcher_version.py "${device}" >"${results}" 2>&1
    if grep -qF 'Watcher Version 1.16' "${results}"
    then
        echo "${device}: Watcher upgraded"
    elif grep -q 'Remote Device Error: waiting for device timed out' "${results}"
    then
        echo "${device}: Device reachable but not responding"
    elif grep -q '/data/data/com.mozilla.watcher/files/version.txt: No such file or directory' "${results}"
    then
        echo "${device}: Not upgraded"
    elif grep -q 'Failed to connect to SUT Agent' "${results}"
    then
        echo "${device}: Cannot connect to device"
    else
        cat "${results}" | sed "s/^/${device}: //"
    fi
    rm "${results}"
    if ! ps -ef | grep buildbot | grep -q "${device}"
    then
        echo "${device}: Buildbot not running"
    fi
    if [ -f /builds/${device}/error.flg ]
    then
        cat /builds/${device}/error.flg | sed "s/^/${device}: error.flg: /"
    fi
done
