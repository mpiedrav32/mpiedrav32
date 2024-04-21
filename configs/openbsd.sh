#!/bin/sh
OPENBSD_HDD=openbsd71.qcow2
OPENBSD_ISO=install71.iso
# qemu-img create -f qcow2 $OPENBSD_HDD 10g
# qemu-system-x86_64 -enable-kvm -smp 4 -m 2048 -hda $OPENBSD_HDD -cdrom $OPENBSD_ISO
#qemu-system-x86_64 -enable-kvm -smp 4 -m 2048 -hda $OPENBSD_HDD
qemu-system-x86_64 -enable-kvm -smp 4 -m 2048 -hda $OPENBSD_HDD -display none -device e1000,netdev=net0 -netdev user,id=net0,hostfwd=tcp::5555-:22
