#!/bin/bash

url="${1}"
curl -L "${url}" | patch -p1 -i -
echo "${url}" | sed -n 's/https:\/\/bug\([0-9]*\)\.bugzilla\.mozilla\.org\/attachment\.cgi?id=\([0-9]*\)/https:\/\/bugzilla.mozilla.org\/page.cgi?id=splinter.html\&bug=\1\&attachment=\2/p' | xargs open
