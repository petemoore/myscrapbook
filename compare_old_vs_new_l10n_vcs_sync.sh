#!/bin/bash

cd "$(dirname "${0}")"
[ ! -f all_l10n_git_repos ] && curl -q 'http://git.mozilla.org/'  | sed -n 's/.*p=releases\/l10n\/\([^\/]*\)\/\([a-z]*\)\.git;a=.*/\1 \2/p' > all_l10n_git_repos

while read locale project
do
    staging_url="http://github.com/petermoore/l10n-${locale}-${project}.git"
    prod_url="http://git.mozilla.org/releases/l10n/${locale}/${project}.git"
    echo "Comparing ${locale} ${project}"
    echo "==========${locale}=${project}" | sed 's/./=/g'
    git ls-remote "${staging_url}" > staging
    git ls-remote "${prod_url}" > prod
    diff staging prod
done < all_l10n_git_repos
