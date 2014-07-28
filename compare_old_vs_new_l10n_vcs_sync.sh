#!/bin/bash

cd "$(dirname "${0}")"
[ ! -f all_l10n_git_repos ] && curl -q 'http://git.mozilla.org/'  | sed -n 's/.*p=releases\/l10n\/\([^\/]*\)\/\([a-z]*\)\.git;a=.*/\1 \2/p' | sort -u > all_l10n_git_repos

while read locale project
do
    staging_url="git@github.com:petermoore/l10n-${locale}-${project}.git"
    prod_url="ssh://gitolite3@git.mozilla.org/releases/l10n/${locale}/${project}.git"
    echo "Comparing ${locale} ${project}"
    echo "==========${locale}=${project}" | sed 's/./=/g'
    git ls-remote "${staging_url}" 2>/dev/null | grep -v 'refs/notes/commits' | sort -k2 > staging
    [ ! -s staging ] && echo "ERROR: Staging repo could not be queried: https://github.com/petermoore/l10n-${locale}-${project}"
    git ls-remote "${prod_url}" | sort -k2 > prod
    diff -y -W 200 -t staging prod
    echo
done < all_l10n_git_repos | tee staging_vs_prod_l10n_git.log
