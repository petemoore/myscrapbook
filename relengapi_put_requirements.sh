#!/bin/bash
cd "$(dirname "${0}")"
cat requirements_staging.txt | ssh "${USER}@relengwebadm.private.scl3.mozilla.com" 'sudo tee /data/releng-stage/src/relengapi/requirements.txt; cd /data/releng-stage/src/relengapi/; sudo ./update'
ssh relengwebadm.private.scl3.mozilla.com sudo ssh web1.stage.releng.webapp.scl3.mozilla.com apachectl graceful
