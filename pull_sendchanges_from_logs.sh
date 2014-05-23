#!/bin/bash

while read url
do
    curl "${url}" 2>/dev/null | gunzip | grep sendchange | sed -n 's/^python [^ ]*\/retry.py/python retry.py/p' | sed 's/buildbot-master[0-9][^ ]*:[0-9][0-9]*/localhost:9036/'
done | tee sendchanges.list | more
