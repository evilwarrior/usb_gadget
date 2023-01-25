#!/bin/bash

CONFIGFS="/sys/kernel/config"
CONFIG_NAME="ikvm_gadget"
CONFIG_ROOT="${CONFIGFS}/usb_gadget/${CONFIG_NAME}"
MS_FUNC_PATH="functions/mass_storage.0" # Mass storage function path
PARTITION_PATH="lun.0"

ms_path="${CONFIG_ROOT}/${MS_FUNC_PATH}/${PARTITION_PATH}"
if [ ! -d $ms_path ]; then
    >&2 echo "Please create the usb gadget first"
    exit 1
fi

cd $ms_path
echo "" > file
exit 0
