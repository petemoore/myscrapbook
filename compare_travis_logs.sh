#!/bin/bash

TOOLS_LOG="$(mktemp -t tools.log.XXXXXXXXXX)"
curl -L 'https://api.travis-ci.org/jobs/46337345/log.txt?deansi=true' > "${TOOLS_LOG}"
BUILDBOT_CONFIGS_LOG="$(mktemp -t buildbot_configs.log.XXXXXXXXXX)"
curl -L 'https://api.travis-ci.org/jobs/46335404/log.txt?deansi=true' > "${BUILDBOT_CONFIGS_LOG}"

TOOLS_SUMMARY="$(mktemp -t tools.summary.XXXXXXXXXX)"
cat "${TOOLS_LOG}" | grep PYTHONPATH | head -1 > "${TOOLS_SUMMARY}"
cat "${TOOLS_LOG}" | sed -n 'H;/ImportError: cannot import name BRANCH_UNITTEST_VARS/h; ${;g;p;}' | sed -n '1,/____ summary ____/p' | sed '1,2d' | sed '$d' | sed 's/.*Jan  8 ..:.. //' >> "${TOOLS_SUMMARY}"

BUILDBOT_CONFIGS_SUMMARY="$(mktemp -t buildbot_configs.summary.XXXXXXXXXX)"
cat "${BUILDBOT_CONFIGS_LOG}" | sed -n '/PYTHONPATH/,/\.\/test-masters.sh -e/p' | sed '$d' | sed 's/.*Jan  8 ..:.. //' > "${BUILDBOT_CONFIGS_SUMMARY}"

vim -d "${TOOLS_SUMMARY}" "${BUILDBOT_CONFIGS_SUMMARY}"

rm "${TOOLS_SUMMARY}" "${BUILDBOT_CONFIGS_SUMMARY}"
rm "${TOOLS_LOG}" "${BUILDBOT_CONFIGS_LOG}"
