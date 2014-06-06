#!/bin/bash -e

filename_fullpath="${1}"
filename_basename="$(basename "${filename_fullpath}")"
scp "${filename_fullpath}" "$(whoami)@relengwebadm.private.scl3.mozilla.com:"
ssh "$(whoami)@relengwebadm.private.scl3.mozilla.com" "
    sudo mv -vi '${filename_basename}' /mnt/netapp/relengweb/pypi/pub/;
    sudo chmod 644 '/mnt/netapp/relengweb/pypi/pub/${filename_basename}';
"
curl -I "http://pypi.pub.build.mozilla.org/pub/${filename_basename}" 2>&1
