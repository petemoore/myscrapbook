#!/bin/bash

cd "$(dirname "${0}")"
pwd
rm -rf properties
rm -rf scripts
hg clone 'http://hg.mozilla.org/build/mozharness' scripts
cd scripts
hg update -C -r production
hg id -i
cd ..
'scripts/scripts/b2g_build.py' '--target' 'generic' '--config' 'b2g/releng-emulator.py' '--b2g-config-dir' 'emulator' '--gaia-languages-file' 'locales/languages_dev.json' '--gecko-languages-file' 'gecko/b2g/locales/all-locales'
cd properties
for file in "$(ls -1)"
do
    cat "${file}"
done
