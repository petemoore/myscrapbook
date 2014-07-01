#!/bin/bash

if [ -z "${1}" ]; then
    image=~/Desktop/"$(ls -1t ~/Desktop/ | grep '^Screen Shot' | head -1)"
else
    image="${1}"
fi

if [ ! -s "${image}" ]; then
    echo "ERROR: File '${image}' is not a file with more than 0 bytes of data, (working dir is '$(pwd)')." >&2
    exit 64
fi

image_name="$(basename "${image}")"
escaped_image_name="$(python -c "import urllib; print urllib.quote('${image_name}');")"

ssh people.mozilla.org "rm -f 'public_html/${image_name}'"
scp "${image}" "people.mozilla.org:'public_html/${image_name}'"
ssh people.mozilla.org "chmod a+r 'public_html/${image_name}'"
echo "http://people.mozilla.org/~pmoore/${escaped_image_name}" | pbcopy
