#!/bin/bash -xv

top_url="${1}"
temp_file="${2}"

del_temp_file=false

if [ -z "${temp_file}" ]
then
    temp_file="$(mktemp -t urls.XXXXXX)"
    del_temp_file=true
fi

temp_page="$(mktemp -t page.html.XXXXXX)"
curl -s "${top_url}" > "${temp_page}"
cat "${temp_page}" | sed -n '/dep:/=' | while read line_no
do
    sed -n -e "$((line_no+1))s/.*\"\(.*\)\".*/http:\/\/packages.ubuntu.com\1/p" "${temp_page}"
done | while read sub_url
do
    if ! grep -Fx "${sub_url}" "${temp_file}" >/dev/null
    then
        target_deb="$(curl -s "${sub_url}/download" | sed -n 's/.*href="\([^"]*ubuntu\.mirror\.iweb\.ca[^"]*\)".*/\1/p')"
        curl -s "${target_deb}" > ~/"Desktop/$(basename "${target_deb}")"
        echo "${sub_url}"
        echo "${sub_url}" >> "${temp_file}"
    fi
done | while read sub_url
do
    "${0}" "${sub_url}" "${temp_file}"
done
rm "${temp_page}"

if [ "${del_temp_file}" = 'true' ]
then
    cat "${temp_file}"
    rm -f "${temp_file}"
fi
