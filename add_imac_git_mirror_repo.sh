#!/bin/bash
echo
cd ~/git
    find . -maxdepth 1 -mindepth 1 -type d | while read dir
    do
        cd "${dir}"
        git remote -v 2>/dev/null | sed -n 's/ssh:\/\/git\//ssh:\/\/imac\/srv\/gitosis\/repositories\//p' | sed 's/(.*//' | sort -u | while read repo url
        do
            git remote add imac "${url}" 2>/dev/null
            git remote set-url imac "${url}"
        echo "${dir#??}: Added ${url}"
    done
    cd ..
done
echo
