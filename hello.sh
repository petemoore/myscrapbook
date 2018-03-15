#!/bin/bash
echo git commit -m "Bug 1399401 - Rolled out generic-worker ${NEW_VERSION} to *STAGING*

This change does _not_ affect any production workers.

This commit was made by running:

    ./upgrade-gw-betas-cu.sh ${NEW_VERSION}

See https://github.com/petemoore/myscrapbook/blob/master/upgrade-gw-betas-cu.sh" -m "${DEPLOY}"
