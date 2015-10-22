#!/bin/bash

say -v boing "let's go mr driver"
for repo in taskcluster-client-go taskcluster-client-java
do
    export GOPATH="$(mktemp -d -t update_clients.XXXXXXXXXX)"
    export PATH="${GOPATH}/bin:${PATH}"
    rm -rf "${GOPATH}"
    go get -t "github.com/taskcluster/${repo}"
    cd "${GOPATH}/src/github.com/taskcluster/${repo}"
    # this will fail if there are changes
    if ! ./build.sh; then
        # but is not the only reason it might fail, so let's see
        # if adding changes fixes it
        git add .
        git commit -m "Regenerated library to pick up latest schema changes"
        # build again to make sure all is ok since git status should report no differences this time, so exit code is reliable
        # note we only push if this second build is successful
        if ./build.sh; then
            if git push; then
                say "New changes pushed, yahoo"
                if [ "${repo}" == 'taskcluster-client-java' ]; then
                    mvn javadoc:javadoc
                    git checkout gh-pages
                    rm -rf apidocs
                    mv target/site/apidocs .
                    git add apidocs
                    git commit -m "Regenerated javadocs after api update(s)"
                    if git push; then
                        say "New javadocs published"
                    else
                        say "Could not publish updated javadocs"
                    fi
                    # TODO: now we should probably bump version number, possibly build again, tag it, and publish to maven central repository...
                    git checkout master
                fi
            else
                say "New changes, but I can't push them"
            fi
        else
            say "Can't auto rebuild, something is seriously wrong"
        fi
    else
        say "All ok"
    fi
    cd
    rm -rf "${GOPATH}"
    echo
    echo =========================================
    echo
done
