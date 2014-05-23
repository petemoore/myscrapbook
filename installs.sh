#!/bin/bash

cd "$(dirname "${0}")"

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install git compizconfig-settings-manager vim openvpn network-manager-openvpn-gnome curl mysql-client-core-5.5 sqlite xul-ext-lightning screen tmux xchat mercurial

# {
#     echo "## Uncomment the following two lines to add software from Canonical's"
#     echo "## 'partner' repository."
#     echo '## This software is not part of Ubuntu, but is offered by Canonical and the'
#     echo '## respective vendors as a service to Ubuntu users.'
#     echo 'deb http://archive.canonical.com/ubuntu quantal partner'
#     echo '# deb-src http://archive.canonical.com/ubuntu quantal partner'
#     echo
#     echo '## This software is not part of Ubuntu, but is offered by third-party'
#     echo '## developers who want to ship their latest software.'
#     echo 'deb http://extras.ubuntu.com/ubuntu quantal main'
#     echo 'deb-src http://extras.ubuntu.com/ubuntu quantal main'
# } | sudo tee -a /etc/apt/sources.list

# sudo apt-get install resolvconf  ?
# skype
# vidyo
# VPNs
# dropbox
# mac printer

{
    echo
    echo 'deb http://repository.spotify.com stable non-free'
} | sudo tee -a /etc/apt/sources.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 94558F59
sudo apt-get update
sudo apt-get install spotify-client

# ./setup_git_repos.sh

# add the following lines to both .bashrc and .profile
# cat << EOF | tee -a ~/.bashrc >> ~/.profile
# 
# export PS1='\[\033[01;35m\]\u\[\033[34m\]@\[\033[36m\]\h\[\033[00m\]:\[\033[01;33m\]\w\[\033[31m\]$(git branch -l 2>/dev/null | sed -n s/^*//p) \$\[\033[00m\] '
# EOF

mkdir -p ~/.config/awesome
ln -s ~/git/mozilla/rc.lua ~/.config/awesome/rc.lua

git config --global push.default current
dropbox start -i
sed -i 's/NoDisplay=true/# NoDisplay=true/' /usr/share/xsessions/awesome.desktop
