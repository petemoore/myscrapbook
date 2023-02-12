#!/bin/bash
set -eu

g -C /Volumes/casesensitive/linux commit -a -m "wip" || true

ssh pmoore@raspberrypi.local '
cd
# git clone git@github.com:raspberrypi/linux.git
cd linux
# git remote add pete git@github.com:petemoore/linux.git
# git remote add work-laptop Peters-MacBook-Pro.local:/Volumes/casesensitive/linux
# git reset --hard HEAD
# git clean -fdx
# git fetch pete
# git checkout rpi-5.15.y-debug-pcie-usb
# git config pull.rebase true
# git pull pete rpi-5.15.y-debug-pcie-usb
git pull work-laptop rpi-5.15.y-debug-pcie-usb
KERNEL=kernel8
# make bcm2711_defconfig
# sed -i 's/^\(CONFIG_LOCALVERSION=.*\)"/\1-pmoore"/' .config
# sed -i 's/-pmoore-pmoore/-pmoore/' .config
# sed -i 's/^# CONFIG_WERROR is not set/CONFIG_WERROR=y/' .config
# make -j4 Image.gz modules dtbs
make -j4 Image.gz
# sudo make modules_install
# sudo cp arch/arm64/boot/dts/broadcom/*.dtb /boot/
# sudo cp arch/arm64/boot/dts/overlays/*.dtb* /boot/overlays/
# sudo cp arch/arm64/boot/dts/overlays/README /boot/overlays/
sudo cp arch/arm64/boot/Image.gz /boot/$KERNEL.img
echo "Kernel rebuilt"
sudo reboot
' | tee ~/rebuildkernel.log
if grep "Kernel rebuilt" ~/rebuildkernel.log; then
  sleep 20
  ssh pmoore@raspberrypi.local 'dmesg | grep brcm-pcie' | tee -a ~/rebuildkernel.log
fi
