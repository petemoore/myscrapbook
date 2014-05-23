#!/bin/bash

cd "$(dirname "${0}")"

# missing directories on foopies for devices defined in devices.json
function missing_devices_on_foopies {
    find ~/"git/mozilla/foopy_reports" -mindepth 4 -maxdepth 4 -type f -name '.exists-in-devices.json.' | xargs rm
    cat ~/git/tools/buildfarm/mobile/devices.json | while read LINE
    do
        [ "${LINE}" != "${LINE//tegra-/}" ] || [ "${LINE}" != "${LINE//panda-/}" ] && device="$(echo "${LINE}" | sed -n 's/.*"\(.*\)".*/\1/p')"
        if [ "${LINE}" != "${LINE//foopy/}" ]
        then
            foopy="$(echo "${LINE}" | sed -n 's/.*"\(foopy[0-9][0-9]*\)".*/\1/p')"
            if [ -n "${foopy}" ] && [ -n "${device}" ]
            then
                if [ ! -d ~/"git/mozilla/foopy_reports/${foopy}/builds/${device}" ]
                then
                    echo "Missing from foopy: ${device} on ${foopy}" && device=
                else
                    touch ~/"git/mozilla/foopy_reports/${foopy}/builds/${device}/.exists-in-devices.json."
                fi
            fi
        fi
    done
    find ~/"git/mozilla/foopy_reports" -mindepth 3 -maxdepth 3 -type d | while read dir
    do
        foopy="$(echo "${dir}" | sed -n 's/.*\/\(foopy[0-9]*\)\/.*/\1/p')"
        device="$(echo "${dir}" | sed -n 's/.*\///p')"
        if [ ! -f "${dir}/.exists-in-devices.json." ]
        then
            echo "Missing from devices.json: ${device} on ${foopy}"
        fi
    done
}

function watcher_upgrade_report {
    OIFS=$IFS
    IFS=/
    find . -maxdepth 4 -mindepth 4 -name install_watcher.log | sort | while read X foopy Y tegra Z
    do
        if grep -q "Watcher Version 1.16" "${foopy}/builds/${tegra}/install_watcher.log"
        then
            echo "SUCCESS: ${tegra} (${foopy})"
        else
            echo "INVESTIGATE: ${tegra} (${foopy})"
        fi
    done | sort -u
    IFS=$OIFS
    for foopy in foopy{28,29,30,31,32}
    do
        ls -1d "${foopy}/builds/tegra"-* | while read tegra
        do
            [ ! -f "${tegra}/install_watcher.log" ] && echo "NO WATCHER UPGRADE LOG FILE: ${tegra}"
        done
    done
}

function remote_watcher_report {
    for ((i=20; i<=139; i++))
    do
        foopy="foopy${i}"
        scp ../watcher_version.py "cltbld@${foopy}:/builds/tools/sut_tools/watcher_version.py" >/dev/null 2>&1 </dev/null
        scp ../all_watcher_versions.sh "cltbld@${foopy}:all_watcher_versions.sh" >/dev/null 2>&1 </dev/null
        ssh "cltbld@${foopy}" './all_watcher_versions.sh' </dev/null | sed "s/^/${foopy}: /"
    done
}

# missing_devices_on_foopies
# watcher_upgrade_report
remote_watcher_report
