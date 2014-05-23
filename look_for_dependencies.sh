#!/bin/bash

read TOP_DIR
while read FILE
do
    echo
    echo "${FILE}"
    echo "${FILE//?/=}"
    FILENAME="$(basename "${FILE}")"
    grep -r "${FILENAME}" "${TOP_DIR}" | grep -v '\/\.git\/' | grep -v '\/\.git\/'
done
