#!/bin/bash -e

cd "/builds/buildbot/$(whoami)/test1"
# first clean up
rm -rf tools
hg clone 'https://hg.mozilla.org/build/tools'
rm -rf buildbot-configs
hg clone 'https://hg.mozilla.org/build/buildbot-configs'
rm -rf buildbotcustom
hg clone 'https://hg.mozilla.org/build/buildbotcustom'

export PATH="/builds/buildbot/$(whoami)/test1/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin"
export PYTHONPATH="/builds/buildbot/$(whoami)/test1:/builds/buildbot/$(whoami)/test1/tools/lib/python"

cd buildbot-configs
curl 'https://bug1030753.bugzilla.mozilla.org/attachment.cgi?id=8458253' | patch -p1 -i -
# ./test-masters.sh
cd ..
ln -f -s buildbot-configs/mozilla-tests/production_config.py localconfig.py
python buildbot-configs/mozilla-tests/mobile_config.py > after
cd buildbot-configs
curl 'https://bug1030753.bugzilla.mozilla.org/attachment.cgi?id=8458253' | patch -p1 -R -i -
find . -name '*.pyc' | xargs rm
cd ..
python buildbot-configs/mozilla-tests/mobile_config.py > before
echo
echo "Results"
diff before after
