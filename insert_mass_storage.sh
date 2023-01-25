#!/bin/bash

CONFIGFS="/sys/kernel/config"
CONFIG_NAME="ikvm_gadget"
CONFIG_ROOT="${CONFIGFS}/usb_gadget/${CONFIG_NAME}"
MS_FUNC_PATH="functions/mass_storage.0" # Mass storage function path
PARTITION_PATH="lun.0"
FILE=$1
CDROM=0

if [ ! -f $FILE ]; then
    >&2 echo "No such file $FILE"
    exit 1
fi
ms_path="${CONFIG_ROOT}/${MS_FUNC_PATH}/${PARTITION_PATH}"
if [ ! -d $ms_path ]; then
    >&2 echo "Please create the usb gadget first"
    exit 1
fi

cd "${CONFIG_ROOT}/${MS_FUNC_PATH}/${PARTITION_PATH}"
echo $FILE > file
echo $CDROM > cdrom
cd $CONFIG_ROOT
# (Re-)enable the device
otg_udc=(/sys/class/udc/*)
if [ "${otg_udc[0]##*/}" != "`cat UDC`" ]; then
    echo ${otg_udc[0]##*/} > UDC
fi
exit 0
