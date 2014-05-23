#!/bin/bash
cd "$(dirname "${0}")"
cat requirements_staging.txt | ssh "${USER}@relengwebadm.private.scl3.mozilla.com" 'sudo tee /data/releng-stage/src/relengapi/requirements.txt; cd /data/releng-stage/src/relengapi/; sudo ./update'
