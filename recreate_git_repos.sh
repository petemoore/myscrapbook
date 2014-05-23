#!/bin/bash

cd "$(dirname "${0}")"

{
echo '#!/bin/bash'
echo
find ~/git -mindepth 1 -maxdepth 1 -type d | while read dir
do
    echo "rm -rf '${dir}'"
    echo "mkdir -p '${dir}'"
    echo "cd '${dir}'"
    echo "git init"
    cd "${dir}"
    git remote -v | grep '(fetch)' | while read remote url type
    do
        echo "git remote add '${remote}' '${url}'"
        echo "git fetch '${remote}'"
    done
    echo
done
} > setup_git_repos.sh

chmod a+x setup_git_repos.sh
