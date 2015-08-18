#!/bin/bash

for repo in taskcluster-client-go taskcluster-client-java
do
    export GOPATH="$(mktemp -d -t update_clients.XXXXXXXXXX)"
    export PATH="${GOPATH}/bin:${PATH}"
    rm -rf "${GOPATH}"
    go get github.com/axw/gocov/gocov
    go get golang.org/x/tools/cmd/cover
    go get golang.org/x/tools/cmd/vet
    go get github.com/pierrre/gotestcover
    go get "github.com/taskcluster/${repo}"

    cd "${GOPATH}/src/github.com/taskcluster/${repo}"
    go get -t ./...
    go install ./...
    # this will fail if there are changes
    if ! ./build.sh; then
        # but is not the only reason it might fail, so let's see
        # if adding changes fixes it
        git add .
        git commit -m "Regenerated library to pick up latest schema changes"
        # build again to make sure all is ok since git status should report no differences this time, so exit code is reliable
        # note we only push if this second build is successful
        ./build.sh && git push
    fi
    cd
    rm -rf "${GOPATH}"
    echo
    echo =========================================
    echo
done
