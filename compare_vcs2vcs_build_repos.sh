#!/bin/bash

clone=false

if $clone
then
    rm -rf ~/build-repos
    mkdir -p ~/build-repos
    ls -1d ~/hg/repo-sync-configs/build-* | grep -v 'build-slaveapi' | sed 's/.*\///' | while read dir
    do
        git clone -o pete git://github.com/petermoore/$dir ~/build-repos/$dir
        cd ~/build-repos/$dir
        git fetch pete
        git remote add mozilla git://github.com/mozilla/$dir
        git fetch mozilla
    done
fi

ls -1 ~/build-repos | while read dir
do
    echo
    echo "${dir}"
    echo "${dir//?/=}"
    git ls-remote git://github.com/petermoore/$dir > ~/$dir.petermoore.list
    git ls-remote git://github.com/mozilla/$dir | grep -vF 'refs/remotes/' > ~/$dir.mozilla.list
    diff ~/$dir.petermoore.list ~/$dir.mozilla.list
done
