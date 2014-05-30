#!/bin/bash

function test_foopy {
    local foopy="${1}"
    local ls_results="${2}"
    echo "Testing ${foopy}..."
    cat "${ls_results}" | while read device_path
    do
        for file in error.flg watcher.log
#       for file in buildbot.tac twistd.log error.flg disabled.flg watcher.log install_watcher.log
#       for file in buildbot.tac
        do
            mkdir -p "${foopy}${device_path}"
            scp -p "cltbld@${foopy}:${device_path}/${file}" "${foopy}${device_path}/${file}"
        done
    done
}

function run_command {
    foopy="${1}"
    command="${2}"
    # in case we cannot connect to foopy, remove it
    rm -rf "${foopy}"
    mkdir "${foopy}"
    ssh -oConnectTimeout=20 -oBatchMode=yes -oStrictHostKeyChecking=no "cltbld@${foopy}" "${command}" </dev/null
}

cd "$(dirname "${0}")"

cat ~/.ssh/known_hosts | sed '/^foopy[0-9]/d' > ~/.ssh/known_hosts2
mv ~/.ssh/known_hosts2 ~/.ssh/known_hosts
for ((i=25; i<=128; i++))
# for i in 122
# for i in 113 116 119 122 124 126
# for ((i=102; i<=108; i++))
do
    ls_results="$(mktemp -t ls.XXXXXXXXXX)"
#   printf -v j "%03d" $i
    run_command "foopy${i}" "find /builds -maxdepth 1 -mindepth 1 -name 'panda-*' -o -name 'tegra-*'" > "${ls_results}" && test_foopy "foopy${i}" "${ls_results}"
    rm "${ls_results}"
done
