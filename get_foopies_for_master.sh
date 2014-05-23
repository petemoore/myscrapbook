#!/bin/bash

master="${1}"
# e.g. master='buildbot-master19'
cd "$(dirname "${0}")/foopy_reports"
find . -name 'buildbot.tac' | while read file
do
    if grep -q "^buildmaster_host.*${master}" "${file}"
    then
        foopy="$(echo "${file}" | cut '-f2' '-d/')"
        echo "${foopy}"
    fi
done | sort -u | while read foopy
do
    echo "Foopy: ${foopy}"
    find "${foopy}" -name buildbot.tac | while read buildbot_tac
    do
        device="$(echo "${buildbot_tac}" | cut '-f3' '-d/')"
        if grep -q "buildmaster_host.*${master}" "${buildbot_tac}"
        then
            echo "Included: ${foopy}/${device}"
        else
            echo "Excluded: ${foopy}/${device}"
        fi
    done
done | sort -u
