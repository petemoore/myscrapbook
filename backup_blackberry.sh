#!/bin/bash

cd  /Users/pmoore/git/blackberry
git pull origin master
find /Volumes/BLACKBERRY1/home/user -type f -print | while read file
do
    new_name="$(echo "${file}" | sed 's/^\/Volumes\/BLACKBERRY1\/home\/user/\/Users\/pmoore\/git\/blackberry/')"
    cp "${file}" "${new_name}"
done
git status
