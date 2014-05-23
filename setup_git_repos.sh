#!/bin/bash

rm -rf '/home/pmoore/git/mozilla'
mkdir -p '/home/pmoore/git/mozilla'
cd '/home/pmoore/git/mozilla'
git init
git remote add 'pete' 'ssh://git/petermoore-mozilla'
git fetch 'pete'

rm -rf '/home/pmoore/git/dotfiles'
mkdir -p '/home/pmoore/git/dotfiles'
cd '/home/pmoore/git/dotfiles'
git init
git remote add 'origin' 'https://github.com/rail/dotfiles'
git fetch 'origin'

rm -rf '/home/pmoore/git/puppet-manifests'
mkdir -p '/home/pmoore/git/puppet-manifests'
cd '/home/pmoore/git/puppet-manifests'
git init
git remote add 'mozilla' 'git@github.com:mozilla/build-puppet-manifests'
git fetch 'mozilla'
git remote add 'pete' 'git@github.com:petemoore/build-puppet-manifests'
git fetch 'pete'

rm -rf '/home/pmoore/git/environment_setup'
mkdir -p '/home/pmoore/git/environment_setup'
cd '/home/pmoore/git/environment_setup'
git init
git remote add 'origin' 'ssh://git/petermoore-environment_setup'
git fetch 'origin'

rm -rf '/home/pmoore/git/pictures'
mkdir -p '/home/pmoore/git/pictures'
cd '/home/pmoore/git/pictures'
git init
git remote add 'origin' 'ssh://git/petermoore-pictures'
git fetch 'origin'

rm -rf '/home/pmoore/git/buildbotcustom'
mkdir -p '/home/pmoore/git/buildbotcustom'
cd '/home/pmoore/git/buildbotcustom'
git init
git remote add 'mozilla' 'git@github.com:mozilla/build-buildbotcustom.git'
git fetch 'mozilla'
git remote add 'pete' 'git@github.com:petemoore/build-buildbotcustom.git'
git fetch 'pete'

rm -rf '/home/pmoore/git/tools'
mkdir -p '/home/pmoore/git/tools'
cd '/home/pmoore/git/tools'
git init
git remote add 'mozilla' 'git@github.com:mozilla/build-tools.git'
git fetch 'mozilla'
git remote add 'pete' 'git@github.com:petemoore/build-tools.git'
git fetch 'pete'

rm -rf '/home/pmoore/git/revolutioner'
mkdir -p '/home/pmoore/git/revolutioner'
cd '/home/pmoore/git/revolutioner'
git init
git remote add 'origin' 'ssh://git/petermoore-revolutioner'
git fetch 'origin'

rm -rf '/home/pmoore/git/puppet'
mkdir -p '/home/pmoore/git/puppet'
cd '/home/pmoore/git/puppet'
git init
git remote add 'mozilla' 'git@github.com:mozilla/build-puppet'
git fetch 'mozilla'
git remote add 'pete' 'git@github.com:petemoore/build-puppet'
git fetch 'pete'

rm -rf '/home/pmoore/git/autobuild'
mkdir -p '/home/pmoore/git/autobuild'
cd '/home/pmoore/git/autobuild'
git init
git remote add 'origin' 'ssh://git/petermoore-autobuild'
git fetch 'origin'

rm -rf '/home/pmoore/git/fast-export'
mkdir -p '/home/pmoore/git/fast-export'
cd '/home/pmoore/git/fast-export'
git init
git remote add 'origin' 'git://repo.or.cz/fast-export.git'
git fetch 'origin'

rm -rf '/home/pmoore/git/blackberry'
mkdir -p '/home/pmoore/git/blackberry'
cd '/home/pmoore/git/blackberry'
git init
git remote add 'origin' 'ssh://git/petermoore-blackberry'
git fetch 'origin'

rm -rf '/home/pmoore/git/freelancing'
mkdir -p '/home/pmoore/git/freelancing'
cd '/home/pmoore/git/freelancing'
git init
git remote add 'origin' 'ssh://git/petermoore-freelancing'
git fetch 'origin'

rm -rf '/home/pmoore/git/elisandra'
mkdir -p '/home/pmoore/git/elisandra'
cd '/home/pmoore/git/elisandra'
git init
git remote add 'origin' 'ssh://git/petermoore-elisandra'
git fetch 'origin'

rm -rf '/home/pmoore/git/deploy_myweb'
mkdir -p '/home/pmoore/git/deploy_myweb'
cd '/home/pmoore/git/deploy_myweb'
git init
git remote add 'origin' 'ssh://git/petermoore-deploy_myweb'
git fetch 'origin'

rm -rf '/home/pmoore/git/tibco-config'
mkdir -p '/home/pmoore/git/tibco-config'
cd '/home/pmoore/git/tibco-config'
git init
git remote add 'origin' 'ssh://git/petermoore-tibco_config'
git fetch 'origin'

rm -rf '/home/pmoore/git/vodafone'
mkdir -p '/home/pmoore/git/vodafone'
cd '/home/pmoore/git/vodafone'
git init
git remote add 'origin' 'ssh://git/petermoore-vodafone'
git fetch 'origin'

rm -rf '/home/pmoore/git/gitosis-admin'
mkdir -p '/home/pmoore/git/gitosis-admin'
cd '/home/pmoore/git/gitosis-admin'
git init
git remote add 'origin' 'ssh://git/gitosis-admin'
git fetch 'origin'

rm -rf '/home/pmoore/git/mozharness'
mkdir -p '/home/pmoore/git/mozharness'
cd '/home/pmoore/git/mozharness'
git init
git remote add 'mozilla' 'git@github.com:mozilla/build-mozharness'
git fetch 'mozilla'
git remote add 'pete' 'git@github.com:petemoore/build-mozharness'
git fetch 'pete'

rm -rf '/home/pmoore/git/finances'
mkdir -p '/home/pmoore/git/finances'
cd '/home/pmoore/git/finances'
git init
git remote add 'pete' 'ssh://git/petermoore-finances'
git fetch 'pete'

rm -rf '/home/pmoore/git/buildbot-configs'
mkdir -p '/home/pmoore/git/buildbot-configs'
cd '/home/pmoore/git/buildbot-configs'
git init
git remote add 'mozilla' 'git@github.com:mozilla/build-buildbot-configs.git'
git fetch 'mozilla'
git remote add 'pete' 'git@github.com:petemoore/build-buildbot-configs.git'
git fetch 'pete'

