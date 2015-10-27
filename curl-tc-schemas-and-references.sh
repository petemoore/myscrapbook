#!/bin/bash

rm -rf ~/tc-refs-and-schemas
mkdir -p ~/tc-refs-and-schemas
cd ~/tc-refs-and-schemas
sed -n -e 's/.*http/http/p' "${GOPATH}/src/github.com/taskcluster/taskcluster-client-go/codegenerator/model/model-data.txt"  | grep taskcluster | grep -v "'" | sort -u | sed -n 's/^http:\/\///p' | sed 's/#$//' | while read FILE
do
    mkdir -p "$(dirname "${FILE}")"
    curl -L "http://${FILE}" > "${FILE}"
done
echo "Look in:" ~/tc-refs-and-schemas "directory"
