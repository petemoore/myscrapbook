#!/bin/bash -e
cd "$(dirname "${0}")"

function usage {
    echo
    echo "This script can be used to deploy relengapi into staging and production. First retrieve"
    echo "the current deployment configuration using:"
    echo "    '$(pwd)/relengapi_get_requirements.sh'"
    echo
    echo "This will download the following files, which you are then free to modify/edit:"
    echo "    * $(pwd)/requirements_staging.txt"
    echo "    * $(pwd)/requirements_prod.txt"
    echo
    echo "After you have finished modifying them, you can deploy your changes, by running this"
    echo "script."
    echo
    echo "Usage: $0 -h"
    echo "Usage: $0 [-p] [-s]"
    echo
    echo "    -h:            Display help."
    echo "    -p:            Deploy to production"
    echo "    -s:            Deploy to staging"
    echo
    echo "Please note you can deploy to both staging and production in one go, by specifying both"
    echo "-p and -s. Please also note, you must specify at least one environment to deploy to, or"
    echo "-h for the help option."
    echo
    echo "EXIT CODES"
    echo "     0        Success."
    echo "    64        No environment specified to deploy to (-p or -s)"
}

function deploy {
    local CLUSTER="${1}"
    local REQUIREMENTS_FILE="${2}"
    shift 2
    local WEB_HEADS=("${@}")
    cat "${REQUIREMENTS_FILE}" | ssh "${USER}@relengwebadm.private.scl3.mozilla.com" "sudo tee '/data/${CLUSTER}/src/relengapi/requirements.txt'; cd '/data/${CLUSTER}/src/relengapi/'; sudo ./update"
    for web_head in "${WEB_HEADS[@]}"; do
        ssh relengwebadm.private.scl3.mozilla.com sudo ssh "${web_head}" apachectl graceful < /dev/null
    done
}

prod_deploy=false
stage_deploy=false

while getopts ':hps' opt
do
    case "${opt}" in
        h)  usage
            exit 0
            ;;
        p)  prod_deploy='true'
            ;;
        s)  stage_deploy='true'
            ;;
        *)  usage >&2
            exit 1
            ;;
    esac
done

if ! "${prod_deploy}" && ! "${stage_deploy}"; then
    echo "Must specify at least one cluster to deploy to (-p or -s)" >&2
    exit 64
fi

"${prod_deploy}"  && deploy releng       requirements_prod.txt web{1,2}.releng.webapp.scl3.mozilla.com
"${stage_deploy}" && deploy releng-stage requirements_staging.txt    web{1}.stage.releng.webapp.scl3.mozilla.com
