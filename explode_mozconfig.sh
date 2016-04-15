#!/bin/bash -e

topsrcdir="${1}"
MOZCONFIG="${2}"

if [ -z "${MOZCONFIG}" ] || [ -z "${topsrcdir}" ]; then
  echo "Please specify a topsrcdir and mozconfig file, e.g." >&2
  echo "  explode_mozconfig.sh ~/hg/mozilla-central browser/config/mozconfigs/win32/nightly" >&2
  exit 64
fi

cd "${topsrcdir}"
# note this works if MOZCONFIG is absolute, or relative to topsrcdir
cd "$(dirname "${MOZCONFIG}")"

function display {
  c="${1}"
  while read LINE; do
    if [ "${LINE#. }" != "${LINE}" ]; then
      file="$(eval "echo ${LINE#. }")"
      display "${file}"
    else
      echo "${LINE}"
    fi
  done < "${c}"
}

display "$(basename "${MOZCONFIG}")"
