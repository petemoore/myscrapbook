#!/bin/bash

function store_status {
    dir_name="${1}"
    cd
    rm -rf "${dir_name}"
    mkdir -p "${dir_name}"
    for filename in error.flg disabled.flg
    do
        find /builds -name "${filename}" -type f | while read file
        do
            new_file="$(echo "${file}" | sed "s/^\\/builds/${dir_name}/")"
            mkdir -p "$(dirname "${new_file}")"
            cp "${file}" "${new_file}"
        done
    done
}

store_status status_before

cd /builds/tools/sut_tools
shopt -s nullglob
ls -1d /builds/{tegra,panda}-* | sed 's/.*\///' | while read device
do
    ./install_watcher.py "${device}" Watcher.1.16.apk 2>&1 | tee "/builds/${device}/install_watcher.log"
done

store_status status_after
