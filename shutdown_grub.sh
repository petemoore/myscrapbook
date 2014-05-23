#!/bin/bash

sudo mount -t msdos /dev/disk0s1 /efi
sudo bless --mount /efi --setBoot --file /efi/EFI/ubuntu/grubx64.efi 
sudo shutdown -h now
