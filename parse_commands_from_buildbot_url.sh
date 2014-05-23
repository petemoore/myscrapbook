#!/bin/bash

function usage {
    script_name="$(basename "${0}")"
    spaces_name="${script_name//?/ }"
    echo "${script_name} -h              Displays this help message"
    echo "${script_name} -u URL          Reads from a buildbot build url (where URL is something like"
    echo "${spaces_name}                 http://<buildbot-host>:<port>/builders/<builder-name>/builds/<build-number>)"
    echo
    echo "This script can parse a buildbot web interface, and retrieve the specific commands that were run for a"
    echo "given build. It then generates a bash script from this set of commands, and outputs it to standard out."
}


url=""

while getopts ':hu:' OPT
do
    case "${OPT}" in
        u) url="${OPTARG}";;
        h) usage
           exit 0;;
        *) echo >&2
           echo "Invalid option specified" >&2
           usage >&2
           exit 64;;
    esac
done

if [ -z "${url}" ] 
then
    usage >&2
    exit 65
fi

echo '#!/bin/bash'
curl -s "${url}" | sed -n 's/.*<li class="alt"><a href=".*\(\/steps\/.*\/logs\/stdio\)">.*<\/a><\/li>.*/\1/p' | while read link
do
    echo
    echo "# from ${url}${link}"
    OUTPUT="$(mktemp -t output.XXXXXXXXXX)"
    curl -s "${url}${link}" > "${OUTPUT}"
    cat "${OUTPUT}" | sed -n 's/^  \(SUT_IP=.*\)/export \1/p'
    cat "${OUTPUT}" | sed -n 's/^  \(SUT_NAME=.*\)/export \1/p'
    cat "${OUTPUT}" | sed -n 's/^  \(PYTHONPATH=.*\)/export \1/p'
    cat "${OUTPUT}" | sed -n 's/^  PWD=\(.*\)/cd \1/p'
    cat "${OUTPUT}" | sed -n 's/^ argv: \[\(.*\)\].*/\1/p' | sed "s/&#39;/'/g;s/&#34;/\"/g" | sed "s/', '/' '/g"
    rm "${OUTPUT}"
done
