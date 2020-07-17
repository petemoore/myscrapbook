#!/bin/bash

export PIFOX_DIR=~/git/PiFox
export PIFOX_VENV=~/pifox-venv
export SCP_HOST=pi
export SCP_REMOTE_DIR=/tftpboot

eval "$(pyenv init -)"
pyenv install -s 2.7.15
pyenv shell 2.7.15
pyenv versions
rm -rf "${PIFOX_VENV}"
virtualenv "${PIFOX_VENV}"
source "${PIFOX_VENV}/bin/activate"
set -eu
pip install --upgrade pip
pip install Pillow
cd "${PIFOX_DIR}"
rm -rf build
mkdir build
cd build
cmake -DCMAKE_TOOLCHAIN_FILE=../toolchains/arm-none-eabi.cmake ..
make
cd ..
mkdir -p dist
cp build/kernel.img dist/kernel7.img

# fetch_firmware downloads standard Raspberry Pi firmware files from the
# Rasperry Pi Foundation github repository into the dist directory.
function fetch_firmware {
  if [ -f "dist/${1}" ]; then
    echo "Keeping cached version of 'dist/${1}'. To fetch a newer version, delete it and rerun all.sh."
  else
    echo "Fetching dist/${1} from github.com/raspberrypi/firmware..."
    curl -# -L "https://github.com/raspberrypi/firmware/blob/master/boot/${1}?raw=true" > "dist/${1}"
  fi
}

# Download required firmware files into dist directory from Raspberry Pi
# Foundation firmware github repository. Skip files that have already been
# downloaded from previous run. Download the latest version from the master
# branch.
#
# It is safe to remove the `dist` directory if you wish to force downloading
# the firmware files again.
fetch_firmware 'LICENCE.broadcom'
fetch_firmware 'bootcode.bin'
fetch_firmware 'fixup.dat'
fetch_firmware 'start.elf'

if [ -n "${SCP_HOST:-}" ] && [ -n "${SCP_REMOTE_DIR:-}" ]; then
  ssh "${SCP_HOST}" "rm -rf ${SCP_REMOTE_DIR}/*"
  scp dist/* "${SCP_HOST}:${SCP_REMOTE_DIR}"
fi
