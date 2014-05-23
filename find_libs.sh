#!/bin/bash

# this script will find imports in tools that
# are not in the ./lib/python subdirectory

cd "$(dirname "${0}")"
dependencies="$(pwd)/dependencies.list"
imported="$(pwd)/imported.list"
importsnonlibs="$(pwd)/importsnonlibs.list"
canberun="$(pwd)/canberun.list"
cantberun="$(pwd)/cantberun.list"
cantberunbutnotimported="$(pwd)/cantberunbutnotimported.list"
canberunbutisalsoimported="$(pwd)/canberunbutisalsoimported.list"
leaveinplace="$(pwd)/leaveinplace.list"
safelymove="$(pwd)/safelymove.list"
cd ~/git/tools

function expand {
    local line="${1}"
    echo "${line}"
    local shorter="$(echo "${line}" | sed 's/\.[^\.]*$//')"
    if [ "${line}" != "${shorter}" ]
    then
        expand "${shorter}"
    fi
}

find . -path ./lib/python -prune -o -name '*.py' -print | while read pythonfile
do
    {
        sed -e :a -e '/\\$/N; s/\\\n//; ta' "${pythonfile}" | sed -n '/from/!s/.*import[[:space:]][[:space:]]*\([^[:space:]].*\)/\1/p' | sed "s/$(printf '\r')//" | sed 's/#.*//' | sed 's/[[:space:]][[:space:]]*as[[:space:]][[:space:]]*[^,]*//g' | sed "s/ //g" | tr ',' '\n'
    
        sed -e :a -e '/\\$/N; s/\\\n//; ta' "${pythonfile}" | sed -n 's/.*from[[:space:]][[:space:]]*\([^[:space:]]*\)[[:space:]][[:space:]]*import[[:space:]][[:space:]]*\([^[:space:]].*\)/\1:\2/p' | sed 's/#.*//' | sed "s/$(printf '\r')//" | sed 's/[[:space:]][[:space:]]*as[[:space:]][[:space:]]*[^,]*//g' | sed "s/ //g" | sed "s/:/ /" | while read package modulelist
        do
            echo "${modulelist}" | tr ',' '\n' | sed "s/^/${package}./"
        done
    } | sed "s/\$/ ${pythonfile//\//\\/}/"
done | sort -u | while read line pythonfile
do
    expand "${line}" | sed "s/\$/ ${pythonfile//\//\\/}/"
done | sort -u | while read importfile referringfile
do
    if echo "${importfile}" | grep '\.\*$' >/dev/null
    then
        without_star="$(echo "${importfile}" | sed 's/\.\*$//')"
        find . -path ./lib/python -prune -o -wholename "*/${without_star//.//}/*.py" -print | sed "s/\$/ ${referringfile//\//\\/}/"
    else
        find . -path ./lib/python -prune -o -wholename "*/${importfile//.//}.py" -print | sed "s/\$/ ${referringfile//\//\\/}/"
    fi
done | sort > "${dependencies}"

cat "${dependencies}" | awk '{print $1}' | sort -u > "${imported}"
cat "${dependencies}" | awk '{print $2}' | sort -u > "${importsnonlibs}"

true > "${canberun}"
true > "${cantberun}"
find . -path ./lib/python -prune -o -name '*.py' -print | while read pythonfile
do
    if grep '__main__' "${pythonfile}" | grep '__name__' >/dev/null
    then
        echo "${pythonfile}" >> "${canberun}"
    else
        echo "${pythonfile}" >> "${cantberun}"
    fi
done

echo "To be left in place"
echo "==================="
echo "These are python scripts which can be run directly, and are not imported by other python code."
cat "${canberun}" | while read file
do
    grep -Fx "${file}" "${imported}" >/dev/null || echo "${file}"
done > "${leaveinplace}"
cat "${leaveinplace}"

echo
echo "Can be moved into lib/python"
echo "============================"
echo "These are python libraries which cannot be run directly, and they are used by other python modules."
cat "${cantberun}" | while read file
do
    grep -Fx "${file}" "${imported}" >/dev/null && echo "${file}"
done > "${safelymove}"
cat "${safelymove}"

echo
echo "Can be deleted?"
echo "==============="
echo "These are python libraries which appear never to be imported, and cannot be run directly."
cat "${cantberun}" | while read file
do
    grep -Fx "${file}" "${imported}" >/dev/null || echo "${file}"
done > "${cantberunbutnotimported}"
cat "${canberunbutisalsoimported}"

echo
echo "Need to be refactored"
echo "====================="
echo "These are python modules which can be run, but are also imported by other modules."
cat "${canberun}" | while read file
do
    grep -Fx "${file}" "${imported}" >/dev/null && echo "${file}"
done > "${canberunbutisalsoimported}"
cat "${canberunbutisalsoimported}"
