#!/bin/bash -eu

if [ "$(uname -s)" != 'Darwin' ]
then
    echo "This is a script for Mac OS X - you are running:" >&2
    uname -a >&2
    exit 67
fi

function usage {
    echo "$(basename "${0}") -h              Displays this help message"
    echo "$(basename "${0}") -i ISO_IMAGE    Create a usb bootable disk based on the image (.iso file) specified"
    echo
    echo "This script is to enable you to create a bootable usb on mac, for example if you want to dual boot"
    echo "your mac with linux. It's a little fiddly, so I created a script for it."
}


iso_image=""

while getopts ':hi:' OPT
do
    case "${OPT}" in
        i) iso_image="${OPTARG}";;
        h) usage
           exit 0;;
        *) echo >&2
           echo "Invalid option specified" >&2
           usage >&2
           exit 64;;
    esac
done

if [ -z "${iso_image}" ]
then
    echo "Please specify an ISO image to use (-i ISO_IMAGE)" >&2
    exit 65
fi

if [ -f "${iso_image}" ] && [ -r "${iso_image}" ]
then
    echo "File '${iso_image}' exists as a regular file and is readable"
else
    echo "Cannot read '${iso_image}' - are you sure you specified a regular file, and that you have read permission to it?" >&2
    echo "I am in the following directory: '$(pwd)'" >&2
    exit 66
fi

if [ -f "${iso_image}.img.dmg" ] 
then
    echo "Deleting existing file '${iso_image}.img.dmg'..."
    rm "${iso_image}.img.dmg"
fi

echo "Converting '${iso_image}' to '${iso_image}.img.dmg'..."
hdiutil convert -format UDRW -o "${iso_image}.img" "${iso_image}"

disk_list_pre="$(mktemp -t disk_list.XXXXXX)"
echo "Please eject your usb disk (if not already ejected) and press 'return' when you are ready to continue"
read
diskutil list > "${disk_list_pre}"
disk_list_post="$(mktemp -t disk_list.XXXXXX)"
diskutil list > "${disk_list_post}"
echo "Please reinsert your usb disk"
while [ -z "$(diff "${disk_list_pre}" "${disk_list_post}" | sed -n 's/^> \/dev\/disk\([0-9][0-9]*\)$/\1/p')" ]
do
    sleep 1
    diskutil list > "${disk_list_post}"
done

new_disk="$(diff "${disk_list_pre}" "${disk_list_post}" | sed -n 's/^> \/dev\/disk\([0-9][0-9]*\)$/\1/p')"
rm "${disk_list_pre}" "${disk_list_post}"

diskutil unmountDisk "/dev/disk${new_disk}"

echo "Preparing usb disk..."
sudo dd "if=${iso_image}.img.dmg" "of=/dev/rdisk${new_disk}" bs=1m
diskutil eject "/dev/disk${new_disk}"
echo "Please remove your usb stick, and press 'return' when you are ready to continue"
read
echo "Now insert the usb drive again, click 'Ignore', reboot your mac, and hold down the 'alt' key"
