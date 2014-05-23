#!/bin/bash -eu

cd "$(dirname "${0}")"

function usage {
    echo
    echo "This script can be used to release relengapi blueprints. It takes care of bumping"
    echo "blueprint version numbers, building them, and uploading them to relengwebadm."
    echo "Please note it does *not* take care of deploying releases to any environment."
    echo
    echo "Usage: $0 -h"
    echo "Usage: $0 -b BLUEPRINT [-b BLUEPRINT_2 -b BLUEPRINT_3 ...]"
    echo
    echo "    -h:                        Display help."
    echo "    -b BLUEPRINT:              The name of a blueprint to release, e.g. mapper or"
    echo "                               relengapi or relengapi-docs. Multiple -b options can be"
    echo "                               specified to release multiple blueprints in one go."
    echo
    echo "EXIT CODES"
    echo "     0        Success."
    echo "     1        Invalid command line arguments specified."
    echo "    64        No blueprints specified to release."
    echo "    65        Unrecognised blueprint name specified for release."
}

function bump_version {
    local old_version="${1}"
    local major="${old_version%.*}"
    local minor="${old_version##*.}"
    echo "${major}.$((minor + 1))"
}

blueprints=()

while getopts ':b:h' opt
do
    case "${opt}" in
        b)  blueprints+=("${OPTARG}")
            ;;
        h)  usage
            exit 0
            ;;
        *)  usage >&2
            exit 1
            ;;
    esac
done

if [ "${#blueprints[@]}" == '0' ]
then
    usage >&2
    exit 1
fi

for blueprint in "${blueprints[@]}"
do
    case "${blueprint}" in
        '')  echo "ERROR: You have specified an empty string for a blueprint name." >&2
             exit 64
             ;;
        mapper)
             echo "Project mapper selected, good choice!"
             local_dir=~/git/mapper
             tag_prefix='relengapi-mapper'
             remote='pete'
             ;;
        relengapi)
             echo "Ah so you want to release the core product, hey?"
             local_dir=~/git/relengapi/base
             tag_prefix='relengapi'
             remote='mozilla'
             ;;
        *)   echo "ERROR: Unrecognised blueprint specified with -b option: '${blueprint}'" >&2
             exit 65
             ;;
    esac
    
    cd "${local_dir}"
    current_version="$(python setup.py -V)"
    echo "Checking git status..."
    git status -s
    echo "Current version: ${current_version}"
    updated_version="$(bump_version "${current_version}")"
#   updated_version="${current_version}"
    echo "Updated version: ${updated_version}"
    cp setup.py setup2.py
    match=("version[[:space:]]*=[[:space:]]*['\"]" "${current_version//./\\.}" "['\"]")
    cat setup2.py | sed "1,/${match[0]}${match[1]}${match[2]}/s/\(${match[0]}\)${match[1]}\(${match[2]}\)/\1${updated_version}\2/" > setup.py
    rm setup2.py
    check_updated_version="$(python setup.py -V)"
    if [ "${check_updated_version}" != "${updated_version}" ]
    then
        echo "ERROR: Something went wrong when bumping version number of '${blueprint}' blueprint - stopping"
        exit 66
    fi
    git add setup.py
    git commit -m "Bumped version number from ${current_version} to ${updated_version}"
    tag_name="${tag_prefix}-${updated_version}"
    git tag "${tag_name}"
    git push "${remote}" master
    git push "${remote}" "${tag_name}"
    rm -rf dist
    python setup.py sdist
    scp "dist/${tag_name}.tar.gz" "${USER}@relengwebadm.private.scl3.mozilla.com:/tmp"
    ssh "${USER}@relengwebadm.private.scl3.mozilla.com" "sudo mv '/tmp/${tag_name}.tar.gz' /mnt/netapp/relengweb/pypi/pub; sudo chmod a+r '/mnt/netapp/relengweb/pypi/pub/${tag_name}.tar.gz'"
done
