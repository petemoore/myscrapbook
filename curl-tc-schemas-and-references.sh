#!/bin/bash

rm -rf ~/tc-refs-and-schemas
mkdir -p ~/tc-refs-and-schemas
cd ~/tc-refs-and-schemas
MODEL="$(mktemp -t "model.XXXXXXXXXX")"
URL_LIST="$(mktemp -t "url-list.XXXXXXXXXX")"
curl -Ls 'https://raw.githubusercontent.com/taskcluster/taskcluster-client-go/master/codegenerator/model-data.txt' > "${MODEL}"
cat "${MODEL}" | sed -n "s/.* = '\(http:\\/\\/schemas\\.taskcluster\\.net\/.*\)'\$/\1/p" | sed 's/#.*//' >> "${URL_LIST}"
cat "${MODEL}" | grep '^http://references\.taskcluster\.net/' >> "${URL_LIST}"
cat "${URL_LIST}" | sort -u | while read URL
do
	FILE="${URL#http://}"
    echo "${URL} =>" ~/"tc-refs-and-schemas/${FILE}"
    mkdir -p "$(dirname "${FILE}")"
    curl -Ls "${URL}" > "${FILE}"
done
rm "${MODEL}"
rm "${URL_LIST}"
