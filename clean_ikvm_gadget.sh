#!/bin/bash

CONFIGFS="/sys/kernel/config"
CONFIG_NAME="ikvm_gadget"
CONFIG_ROOT="${CONFIGFS}/usb_gadget/${CONFIG_NAME}"
STRING_PATH="strings/0x409"
C1_PATH="configs/c.1"
MS_FUNC_PATH="functions/mass_storage.0" # Mass storage function path
KB_FUNC_PATH="functions/hid.0"          # Keyboard function path
M_FUNC_PATH="functions/hid.1"           # Mouse function path

if [ ! -d $CONFIGFS ]; then
    >&2 echo "Configfs mount point not exists"
    exit 1
fi

m_func_link="${CONFIG_ROOT}/${C1_PATH}/$(basename "$M_FUNC_PATH")"
if [ -L $m_func_link ]; then
    rm $m_func_link
fi
kb_func_link="${CONFIG_ROOT}/${C1_PATH}/$(basename "$KB_FUNC_PATH")"
if [ -L $kb_func_link ]; then
    rm $kb_func_link
fi
ms_func_link="${CONFIG_ROOT}/${C1_PATH}/$(basename "$MS_FUNC_PATH")"
if [ -L $ms_func_link ]; then
    rm $ms_func_link
fi
c1_str_path="${CONFIG_ROOT}/${C1_PATH}/${STRING_PATH}"
if [ -d $c1_str_path ]; then
    rmdir $c1_str_path
fi
c1_path="${CONFIG_ROOT}/${C1_PATH}"
if [ -d $c1_path ]; then
    rmdir $c1_path
fi
m_func_path="${CONFIG_ROOT}/${M_FUNC_PATH}"
if [ -d $m_func_path ]; then
    rmdir $m_func_path
fi
kb_func_path="${CONFIG_ROOT}/${KB_FUNC_PATH}"
if [ -d $kb_func_path ]; then
    rmdir $kb_func_path
fi
ms_func_path="${CONFIG_ROOT}/${MS_FUNC_PATH}"
if [ -d $ms_func_path ]; then
    rmdir $ms_func_path
fi
str_path="${CONFIG_ROOT}/${STRING_PATH}"
if [ -d $str_path ]; then
    rmdir "${CONFIG_ROOT}/${STRING_PATH}"
fi
if [ -d $CONFIG_ROOT ]; then
    rmdir $CONFIG_ROOT
fi
modprobe -r usb_f_mass_storage
modprobe -r usb_f_hid
modprobe -r libcomposite
if mountpoint -q -- "$CONFIGFS"; then
    umount $CONFIGFS
fi
exit 0
