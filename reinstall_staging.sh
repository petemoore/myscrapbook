#!/bin/bash
set -e
echo 'Host hg.mozilla.org git.mozilla.org
    User pmoore@mozilla.com
    Compression yes 
    ServerAliveInterval 300' > ~/.ssh/config
chmod 600 ~/.ssh/config
rm -rf ~/staging-release
cd
git clone https://github.com/petemoore/staging-release.git
rm -rf /builds/buildbot/pmoore/staging/
rm -rf ~/venvs
virtualenv ~/venvs/staging-release
source ~/venvs/staging-release/bin/activate
pip install -r ~/staging-release/requirements.txt
cd staging-release
python staging_setup.py -c config/pmoore_esr31.ini -b 1040319 -v 1.0 -r fennec
cd /builds/buildbot/pmoore/staging/staging
deactivate
source /builds/buildbot/pmoore/staging/release_runner/bin/activate
pip uninstall buildbot
cd /builds/buildbot/pmoore/staging/staging/buildbot/master
python setup.py install
deactivate
cp -pr /builds/buildbot/pmoore/staging/staging/buildbot-configs /builds/buildbot/pmoore/staging/
nohup /builds/buildbot/pmoore/staging/release-kickoff/shipit.sh >~/shipit.log 2>&1 &
hg -R /builds/buildbot/pmoore/staging/staging/buildbotcustom up -r production-0.8
hg -R /builds/buildbot/pmoore/staging/staging/buildbot up -r production-0.8
hg -R /builds/buildbot/pmoore/staging/staging/buildbot-configs up -r production
ln -s /builds/buildbot/pmoore/staging/staging/{buildbot-configs/mozilla,master}/staging_release-fennec-mozilla-esr31.py.template
ln -s /builds/buildbot/pmoore/staging/staging/{buildbot-configs/mozilla,master}/release-fennec-mozilla-esr31.py.template
ln -s /builds/buildbot/pmoore/staging/staging/{buildbot-configs/mozilla,master}/release-fennec-mozilla-esr31.py
cd /builds/buildbot/pmoore/staging/staging
echo -e 'reset-db:
\trm master/state.sqlite
\tcd master && $(BUILDBOT) upgrade-master $$PWD' >> Makefile
make start
