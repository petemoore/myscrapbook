#!/bin/bash
cd "$(dirname "${0}")"

ssh github-sync2.dmz.scl3.mozilla.com sudo find /opt/vcs2vcs/vcs_sync/build/conversion/ -mindepth 3 -maxdepth 3 -name published-to-mapper | while read file
do
    project="$(echo "${file}" | cut -d/ -f7)"
    ssh "github-sync2.dmz.scl3.mozilla.com" sudo cat "${file}" > "${project}.source.mapfile" < /dev/null
    curl -s "https://api.pub.build.mozilla.org/mapper/${project}/mapfile/full" > "${project}.mapper.mapfile"
    md5 "${project}.source.mapfile" "${project}.mapper.mapfile"
    diff "${project}.source.mapfile" "${project}.mapper.mapfile"
done
