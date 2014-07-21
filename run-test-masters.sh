#!/bin/bash -e

cd '/builds/buildbot/pmoore/test1'
# first clean up
rm -rf tools
hg clone 'https://hg.mozilla.org/build/tools'
rm -rf buildbot-configs
hg clone 'https://hg.mozilla.org/build/buildbot-configs'
rm -rf buildbotcustom
hg clone 'https://hg.mozilla.org/build/buildbotcustom'

export PATH='/builds/buildbot/pmoore/test1/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin'
export PYTHONPATH='/builds/buildbot/pmoore/test1:/builds/buildbot/pmoore/test1/tools/lib/python'

cd buildbot-configs
curl 'https://bug1030753.bugzilla.mozilla.org/attachment.cgi?id=8458253' | patch -p1 -i -
./test-masters.sh
