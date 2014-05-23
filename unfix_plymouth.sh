#!/bin/bash -e

cat ~/grub | sudo tee /etc/default/grub
cat ~/modules | sudo tee /etc/initramfs-tools/modules
sudo rm /etc/initramfs-tools/conf.d/splash
rm ~/grub
rm ~/modules
sudo update-grub2
sudo update-initramfs -u
