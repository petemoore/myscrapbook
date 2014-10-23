#!/bin/bash -eu

# Explicitly unset any pre-existing environment variables to avoid variable collision
unset BUG_ID ATTACHMENT_ID

function usage {
    echo
    echo "This script can be used to xpi sign an artifact attached to a bugzilla bug."
    echo "It then can upload the signed version back to the same bug."
    echo
    echo "USAGE"
    echo "     1) $(basename "${0}") -h"
    echo "     2) $(basename "${0}") -b BUG_ID -a ATTACHMENT_ID"
    echo
    echo "OPTIONS"
    echo "    -a ATTACHMENT_ID               Download the unsigned version of the xpi file for signing from"
    echo "                                   https://bugzilla.mozilla.org/attachment.cgi?id=<ATTACHMENT_ID>."
    echo "    -b BUG_ID                      Attach the generated signed xpi file to bug BUG_ID."
    echo "    -h:                            Display help."
    echo
    echo "EXAMPLES"
    echo "    $(basename "${0}") -b 1234567 -a 8765432"
    echo
    echo "EXIT CODES"
    echo "     0        Success"
    echo "     1        Bad command line options specified"
    echo "    64        Could not download unsigned xpi bugzilla attachment"
    echo "    65        Could not upload signed xpi bugzilla attachment"
}

# Simple function to output the name of this script and the options that were passed to it
function command_called {
    echo -n "Command called:"
    for ((INDEX=0; INDEX<=$#; INDEX+=1))
    do
        echo -n " '${!INDEX}'"
    done
    echo ''
    echo "From directory: '$(pwd)'"
}

set +u
command_called "${@}" | sed '1s/^/  * /;2s/^/    /'
set -u

echo "  * Parsing parameters of $(basename "${0}")..."
# Parse parameters passed to this script
while getopts ":a:b:h" opt; do
    case "${opt}" in
        a)  ATTACHMENT_ID="${OPTARG}"
            ;;
        b)  BUG_ID="${OPTARG}"
            ;;
        h)  echo "  * Help option requested"
            usage
            exit 0
            ;;
    esac
done

echo "  * Validating parameters..."

if [ -z "${ATTACHMENT_ID-}" ]; then
    echo "ERROR: no attachment id specified (-a ATTACHMENT_ID). Use -h option for help." >&2
    exit 1
elif ! [ "${ATTACHMENT_ID}" -eq "${ATTACHMENT_ID}" ] 2>/dev/null || [ "${ATTACHMENT_ID}" -lt 0 ] 2>/dev/null; then
    echo "ERROR: attachment id specified (-a '${ATTACHMENT_ID}') must be a positive integer (e.g. -a 8765432)"
    exit 1
else
    # normalise - e.g. remove any trailing + sign etc
    let ATTACHMENT_ID=ATTACHMENT_ID
    echo "  * Attachment id is a positive integer (${ATTACHMENT_ID})"
fi

if [ -z "${BUG_ID-}" ]; then
    echo "ERROR: no bug id specified (-b BUG_ID). Use -h option for help." >&2
    exit 1
elif ! [ "${BUG_ID}" -eq "${BUG_ID}" ] 2>/dev/null || [ "${BUG_ID}" -lt 0 ] 2>/dev/null; then
    echo "ERROR: bug id specified (-b '${BUG_ID}') must be a positive integer (e.g. -b 1234567)"
    exit 1
else
    # normalise - e.g. remove any trailing + sign etc
    let BUG_ID=BUG_ID
    echo "  * Bug id is a positive integer (${BUG_ID})"
fi

echo "  * All parameters tested and valid"

echo "  * Downloading unsigned xpi file from https://bugzilla.mozilla.org/attachment.cgi?id=${ATTACHMENT_ID}..."
ssh signing4.srv.releng.scl3.mozilla.com "
    sudo mkdir -p '/builds/signing/xpi-signing-work/bug${BUG_ID}/attachment${ATTACHMENT_ID}/signed-hotfix'
    sudo curl -L -s 'https://bugzilla.mozilla.org/attachment.cgi?id=${ATTACHMENT_ID}' -o '/builds/signing/xpi-signing-work/bug${BUG_ID}/attachment${ATTACHMENT_ID}/unsigned.xpi'
    sudo unzip '/builds/signing/xpi-signing-work/bug${BUG_ID}/attachment${ATTACHMENT_ID}/unsigned.xpi' -d '/builds/signing/xpi-signing-work/bug${BUG_ID}/${ATTACHMENT_ID}/signed-hotfix'
    sudo chown -R cltsign:cltsign '/builds/signing/xpi-signing-work/bug${BUG_ID}'

    # this step is failing due to interactive passphrase request - probably need to use expect script :(

    sudo su cltsign -c 'signtool -d /builds/signing/non-server-keys/2013-xpi -k \"Mozilla Corporation - DigiCert Inc\" -X -Z /builds/signing/xpi-signing-work/bug${BUG_ID}/attachment${ATTACHMENT_ID}-signed /builds/signing/xpi-signing-work/bug${BUG_ID}/signed-hotfix'
"
