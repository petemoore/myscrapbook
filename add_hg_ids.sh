#!/bin/bash

cd ~/git/firefox
total=0
lines="$(cat gecko-mapfile | wc -l)"
while read git_id hg_id
do
    git notes add -m "hg id: ${hg_id}" "${git_id}"
    echo "$((++total))/${lines} ($((total * 100 / lines))%): ${git_id} ${hg_id}"
done < gecko-mapfile
