#!/bin/bash
set -eu

g -C /Volumes/casesensitive/linux commit -a -m "wip" || true

ssh pmoore@raspberrypi.local '
set -eu
sudo apt-get install -y git bc bison flex libssl-dev make
cd
rm -rf linux
git clone https://github.com/raspberrypi/linux
cd linux
git remote add pete git@github.com:petemoore/linux.git
git remote add work-laptop pmoore@Peters-MacBook-Pro.local:/Volumes/casesensitive/linux
git reset --hard HEAD
git clean -fdx
git fetch pete
git checkout rpi-5.15.y-debug-pcie-usb
git config pull.rebase true
git pull pete rpi-5.15.y-debug-pcie-usb
git pull work-laptop rpi-5.15.y-debug-pcie-usb
export KERNEL=kernel8 # online it suggests not to export, but i don't see how it would reach make subprocess if we don't
make bcm2711_defconfig
sed -i 's/^\(CONFIG_LOCALVERSION=.*\)"/\1-pmoore"/' .config
sed -i 's/-pmoore-pmoore/-pmoore/' .config
sed -i 's/^# CONFIG_WERROR is not set/CONFIG_WERROR=y/' .config
# sed -i 's/^\(CONFIG_LOG_BUF_SHIFT=\).*/\118/' .config # do not need to change default as we update /boot/cmdline.txt later
make -j4 Image.gz modules dtbs
sudo make modules_install
sudo cp arch/arm64/boot/dts/broadcom/*.dtb /boot/
sudo cp arch/arm64/boot/dts/overlays/*.dtb* /boot/overlays/
sudo cp arch/arm64/boot/dts/overlays/README /boot/overlays/
sudo cp arch/arm64/boot/Image.gz /boot/$KERNEL.img
cat /boot/cmdline.txt | sed 's/ log_buf_len=[^ ]*//' | sed 's/$/ log_buf_len=64M/' | sudo tee /boot/cmdline.txt
echo "Kernel rebuilt"
sleep 3
sudo reboot
' | tee ~/rebuildkernel.log
if grep "Kernel rebuilt" ~/rebuildkernel.log; then
  sleep 20
  ssh pmoore@raspberrypi.local 'dmesg | grep brcm-pcie' | tee -a ~/rebuildkernel.log
fi
