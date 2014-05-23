#!/bin/bash

curl 'http://dev-master01.build.scl1.mozilla.com:8036/one_line_per_build?numbuilds=200' 2>/dev/null | sed -n 's/.*<a href="\([^"]*\)">#[0-9][0-9]*<\/a>.*/http:\/\/dev-master01.build.scl1.mozilla.com:8036\/\1/p' | while read url
do
    curl "${url}" 2>/dev/null | grep -q 'pmoore' && echo "${url}"
done
