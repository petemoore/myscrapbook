#!/bin/bash
cd "$(dirname "${0}")"

ssh github-sync4.dmz.scl3.mozilla.com ls -1 /home/pmoore/vcs_sync/build/conversion/build-*/.hg/published-to-mapper </dev/null | while read file
do
    project="$(echo "${file}" | cut -d/ -f7)"
    scp "github-sync4.dmz.scl3.mozilla.com:${file}" "${project}.source.mapfile"
    curl -s "https://api-pub-build.allizom.org/mapper/${project}/mapfile/full" > "${project}.mapper.mapfile"
    md5 "${project}.source.mapfile" "${project}.mapper.mapfile"
    diff "${project}.source.mapfile" "${project}.mapper.mapfile"
done
