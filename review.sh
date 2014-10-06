#!/bin/bash

url="${1}"
curl -L "${url}" | patch -p1 -i -
