[ -f ~/grub ] && exit 64
[ -f ~/modules ] && exit 65
[ -f /etc/initramfs-tools/conf.d/splash ] && exit 66
cp /etc/default/grub ~
cp /etc/initramfs-tools/modules ~
# sed 's/GRUB\_CMDLINE\_LINUX\_DEFAULT\=\"quiet\ splash\"/GRUB\_CMDLINE\_LINUX\_DEFAULT\=\"quiet\ splash\ nomodeset\ video\=uvesafb\:mode\_option\='$resolution'\,mtrr\=3\,scroll\=ywrap\"/g' /etc/default/grub > ./newgrub
sed 's/GRUB\_CMDLINE\_LINUX\_DEFAULT\=.*/GRUB\_CMDLINE\_LINUX\_DEFAULT\=\"quiet\ splash\ video\=795\"/g' /etc/default/grub > ./newgrub
sudo mv -f ./newgrub /etc/default/grub
sed 's/\#GRUB\_GFXMODE\=.*/GRUB\_GFXMODE\=1280x1024/g' /etc/default/grub > ./newgrub
sudo mv -f ./newgrub /etc/default/grub
# sudo echo "uvesafb mode_option=$resolution mtrr=3 scroll=ywrap" | sudo tee -a /etc/initramfs-tools/modules
echo FRAMEBUFFER=y | sudo tee /etc/initramfs-tools/conf.d/splash
sudo update-grub2
sudo update-initramfs -u
echo "The resolution should be fixed after a reboot"
