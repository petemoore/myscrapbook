#!/bin/bash

TEMP_FILE="$(mktemp -t gitstatus.XXXXXXXXXX)"
cd ~/git
find . -mindepth 1 -maxdepth 1 -type d | while read DIR
do
    cd "${DIR}"
    git status --porcelain > "${TEMP_FILE}"
    if [ $(cat "${TEMP_FILE}" | wc -l) -gt 0 ]
    then
        echo
        pwd
        pwd | sed 's/./=/g'
        echo
        git status
    fi
    cd ..
done
echo
rm "${TEMP_FILE}"
