#!/bin/bash
cd "$(dirname "${0}")"
scp "${USER}@relengwebadm.private.scl3.mozilla.com:/data/releng-stage/src/relengapi/requirements.txt" requirements_staging.txt
scp "${USER}@relengwebadm.private.scl3.mozilla.com:/data/releng-stage/src/relengapi/settings.py"      settings_staging.py
scp "${USER}@relengwebadm.private.scl3.mozilla.com:/data/releng/src/relengapi/requirements.txt"       requirements_prod.txt
scp "${USER}@relengwebadm.private.scl3.mozilla.com:/data/releng/src/relengapi/settings.py"            settings_prod.py
