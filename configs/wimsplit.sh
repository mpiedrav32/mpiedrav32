#!/bin/sh
# Split Windows installation image (5 GB as of March 2022) for a FAT filesystem
# See `man wimsplit`

# A Debian way to split install.wim from the Windows 10/11 ISO

# The main Windows 10 or Windows 11 installer file, `install.wim`, is over 4 GB.

# However, it won't fit a FAT32 partition on a USB drive.

# EFI[1] uses the FAT file system for booting.
# That's why GPT requires a FAT partition under EFI.

# Thus, it's necessary to split the WIM disk image file into manageable chunks.
# For instance, 1 GB each.

# ```sh
# sudo apt install rsync wimtools

# sudo mount -o loop [windows-iso-file] [windows-iso-mount]

# sudo mount [usb-drive-device] [usb-mount]

# rsync -a --exclude install.wim [windows-iso-mount]/ [usb-mount]/

# wimsplit [windows-iso-mount]/sources/install.wim [usb-mount]/sources/install.swm 1000
# ```

# Splitting and writing the chunks will take a while.

# They'll appear as `install.swm` (not "install1"), `install2.swm`, etc.
# in the `sources` directory from the USB drive.

# During Windows installation, these chunks are joined.

# WIM (Windows Imaging Format)[2] is the disk image format for the Windows installer
# since Windows Vista.

# [1] https://en.wikipedia.org/wiki/EFI_system_partition

# [2] https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/work-with-windows-images?view=windows-11

# ISO image from Microsoft
# https://www.microsoft.com/en-us/software-download/
ISO_FILE=""
ISO_MOUNT=""

# USB bootable device for installing Windows
USB_DEVICE=""
USB_MOUNT=""

# Original Windows installation image
WIM_FILE="$ISO_MOUNT/sources/install.wim"

# Filename pattern for splitting installation image
# Parts will be named `install.swm`, `install2.swm`, `install3.swm`, etc.
WIM_PART="$USB_MOUNT/sources/install.swm"

# Maximum size of each part, in MiB (power-of-2 megabytes)
WIM_SIZE=1000

sudo apt install rsync wimtools

sudo mount -o loop $ISO_FILE $ISO_MOUNT

sudo mount $USB_DEVICE $USB_MOUNT

rsync -a --exclude=$WIM_FILE $ISO_MOUNT $USB_MOUNT

wimsplit $WIM_FILE $WIM_PART $WIM_SIZE