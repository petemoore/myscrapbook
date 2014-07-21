#!/bin/bash -e

buildbot_test_dir="/builds/buildbot/$(whoami)/test1"
cd "${buildbot_test_dir}"
# first clean up
rm -rf tools
hg clone 'https://hg.mozilla.org/build/tools'
rm -rf buildbot-configs
hg clone 'https://hg.mozilla.org/build/buildbot-configs'
rm -rf buildbotcustom
hg clone 'https://hg.mozilla.org/build/buildbotcustom'

export PATH="${buildbot_test_dir}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin"
export PYTHONPATH="${buildbot_test_dir}:${buildbot_test_dir}/tools/lib/python"

cd buildbot-configs
curl 'https://bug1030753.bugzilla.mozilla.org/attachment.cgi?id=8458253' | patch -p1 -i -
ln -f -s "${buildbot_test_dir}/buildbot-configs/mozilla-tests/production_config.py" "${buildbot_test_dir}/localconfig.py"
./test-masters.sh
cd ..
python buildbot-configs/mozilla-tests/mobile_config.py > after
cd buildbot-configs
curl 'https://bug1030753.bugzilla.mozilla.org/attachment.cgi?id=8458253' | patch -p1 -R -i -
find . -name '*.pyc' | xargs rm
cd ..
python buildbot-configs/mozilla-tests/mobile_config.py > before
diff -y -d -W 236 before after > ~/diff-results
view ~/diff-results
