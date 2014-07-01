#!/bin/bash

curl -s -L 'https://hg.mozilla.org/build/tools/raw-file/tip/buildfarm/mobile/devices.json' | sed -n 's/.*\(foopy[0-9][0-9]*\).*/\1/p' | sort -u | while read foopy; do ssh -o StrictHostKeyChecking=no "cltbld@${foopy}" 'shopt -s nullglob; for file in /builds/{tegra,panda}-[0-9]*/error.flg; do echo "$(echo "${file}" | cut -d/ -f3): $(cat "${file}")"; done' </dev/null 2>/dev/null; done | sort -u
