#!/bin/bash

cd "$(dirname "${0}")"

cat bugs.list | sed 's/[^0-9].*//' | sort -run | while read line; do curl "https://bugzilla.mozilla.org/show_bug.cgi?id=${line}" 2>/dev/null | sed -n 's/.*document\.title = "//p' | sed 's/";$//' | sed "s/\\\\//g"; done | while read Bug NUM minus rest; do echo "<p><a href=\"https://bugzilla.mozilla.org/show_bug.cgi?id=${NUM}\" title=\"https://bugzilla.mozilla.org/show_bug.cgi?id=${NUM}\" target=\"_blank\">Bug ${NUM} &ndash; ${rest}</a><br/></p>"; done
