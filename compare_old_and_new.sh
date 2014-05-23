#!/bin/bash

cd ~/git/build-tools/release
# git clean -fdx
# git checkout -f master || exit
# cp ~/dummy-test-config.cfg updates/
# rm -rf ~/old_version.log
# START_TIME="$(date +%s)"
# date > ~/old_version.log
# # bash final-verification.sh $(ls ~/updates/*.cfg | sed 's/.*\///') 2>&1 | tee ~/old_version.log
# # bash final-verification.sh dummy-test-config.cfg moz18-firefox-linux.cfg moz18-firefox-linux-major.cfg moz18-firefox-mac.cfg moz18-firefox-mac-major.cfg moz18-firefox-win32.cfg moz18-firefox-win32-major.cfg 2>&1 | tee ~/old_version.log
# bash final-verification.sh dummy-test-config.cfg 2>&1 | tee -a ~/old_version.log
# date >> ~/old_version.log
# STOP_TIME="$(date +%s)"
# echo "Time taken: $((STOP_TIME-START_TIME)) seconds" >> ~/old_version.log
# chmod 400 ~/old_version.log
# git clean -fdx
# git checkout -f master
# git checkout -f bug628796 || exit
# git clean -fdx
cp ~/dummy-test-config.cfg updates/
rm -rf ~/new_version.log
# ./final-verification.sh -p 16 $(ls ~/updates/*.cfg | sed 's/.*\///') 2>&1 | tee ~/new_version.log
# ./final-verification.sh -p 16 dummy-test-config.cfg moz18-firefox-linux.cfg moz18-firefox-linux-major.cfg moz18-firefox-mac.cfg moz18-firefox-mac-major.cfg moz18-firefox-win32.cfg moz18-firefox-win32-major.cfg 2>&1 | tee ~/new_version.log
./final-verification.sh dummy-test-config.cfg 2>&1 | tee ~/new_version.log
chmod 400 ~/new_version.log
cd
cat old_version.log | sed 's/https/http/g' | sed -n 's/FAIL: no \(.*\) update found for \(.*\)/\2 \1/p' | sort -u > old_fails.log
cat new_version.log | sed 's/https/http/g' | sed -n 's/.*FAILURE: Could not retrieve update.xml from \(.*\) for patch type(s) '\''\(.*\)'\''$/\1 \2/p' | sort -u > new_fails.log

diff old_fails.log new_fails.log
