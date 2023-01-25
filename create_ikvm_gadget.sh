#!/bin/bash

shell_path="$(cd -- "$(dirname "$0")" >/dev/null 2>&1; pwd -P)"

CONFIGFS="/sys/kernel/config"
CONFIG_NAME="ikvm_gadget"
CONFIG_ROOT="${CONFIGFS}/usb_gadget/${CONFIG_NAME}"
STRING_PATH="strings/0x409"
C1_PATH="configs/c.1"
MS_FUNC_PATH="functions/mass_storage.0" # Mass storage function path
PARTITION_PATH="lun.0"
KB_FUNC_PATH="functions/hid.0"          # Keyboard function path
M_FUNC_PATH="functions/hid.1"           # Mouse function path

VENDOR_ID="0x1d6b"                      # Linux Foundation
PRODUCT_ID="0x0104"                     # Multifunction Composite Gadget
DEVICE_VER="0x0100"                     # v1.0.0 Device Release Number
USB_PROTO="0x0200"                      # USB2.0
DEVICE_CLASS="0xEF"                     # Miscellaneous
DEVICE_SUBCLASS="0x02"
DEVICE_PROTO="0x01"                     # Interface Association Descriptor
MANUFACTURER="Linux Foundation"
PRODUCT="iKVM Composite Gadget"
SERIALNUMBER="IKVM-USBGADGET"

C1_NAME="Config 1: iKVM HID keyboard/mouse and mass storage"
# If your iKVM can be powered by host with 5V USB cable
# Modify ATTRIBUTES="0x80" and MAX_POWER as suitable value
ATTRIBUTES="0xC0"                       # D6=1 self-powered, D5=0 no remote wakeup
MAX_POWER=0                             # iKVM is powered by adapter, rather than by host

# Mass Storage Attributes
REMOVABLE=1
NOFUA=0

# HID Keyboard Attributes
KB_SUBCLASS=1
KB_PROTO=1
KB_REPORT_LEN=8

# HID Mouse Attributes
M_SUBCLASS=1
M_PROTO=2
M_REPORT_LEN=4

# HID Report Descriptor Generator
REPORT_DESC_SCRIPT="${shell_path}/gen_report_desc.py" # The generator script path of binary file of report descriptor

if [ ! -d $CONFIGFS ]; then
    >&2 echo "Configfs mount point not exists"
    exit 1
fi
# Prepare configfs modules and folders
if ! mountpoint -q -- "$CONFIGFS"; then
    mount -t configfs none $CONFIGFS
fi
modprobe libcomposite
modprobe usb_f_mass_storage
mkdir -p $CONFIG_ROOT
mkdir -p "${CONFIG_ROOT}/${STRING_PATH}"
mkdir -p "${CONFIG_ROOT}/${C1_PATH}/${STRING_PATH}"
mkdir -p "${CONFIG_ROOT}/${MS_FUNC_PATH}/${PARTITION_PATH}"
mkdir -p "${CONFIG_ROOT}/${KB_FUNC_PATH}"
mkdir -p "${CONFIG_ROOT}/${M_FUNC_PATH}"
# Config USB basic information
cd $CONFIG_ROOT
echo $VENDOR_ID > idVendor
echo $PRODUCT_ID > idProduct
echo $DEVICE_VER > bcdDevice
echo $USB_PROTO > bcdUSB
echo $DEVICE_CLASS > bDeviceClass
echo $DEVICE_SUBCLASS > bDeviceSubClass
echo $DEVICE_PROTO > bDeviceProtocol
cd "${CONFIG_ROOT}/${STRING_PATH}"
echo $SERIALNUMBER > serialnumber
echo $MANUFACTURER > manufacturer
echo $PRODUCT > product
# Create configurations
cd "${CONFIG_ROOT}/${C1_PATH}"
echo $ATTRIBUTES > bmAttributes
echo $MAX_POWER > MaxPower
cd "${CONFIG_ROOT}/${C1_PATH}/${STRING_PATH}"
echo $C1_NAME > configuration
# Create mass storage function
cd "${CONFIG_ROOT}/${MS_FUNC_PATH}/${PARTITION_PATH}"
echo $REMOVABLE > removable
echo $NOFUA > nofua
# Create report descriptor binaries
kb_report_desc="${shell_path}/kb_report_desc.bin"
m_report_desc="${shell_path}/m_report_desc.bin"
$REPORT_DESC_SCRIPT $kb_report_desc $m_report_desc
if [ $? != 0 ]; then
    clean_shell_path="${shell_path}/clean_ikvm_gadget.sh"
    $clean_shell_path
    >&2 echo "Generate report descriptor binaries failed"
    exit 1
fi
# Create keyboard function
cd "${CONFIG_ROOT}/${KB_FUNC_PATH}"
[ `cat subclass` == 0 ] && echo $KB_SUBCLASS > subclass
[ `cat protocol` == 0 ] && echo $KB_PROTO > protocol
[ `cat report_length` == 0 ] && echo $KB_REPORT_LEN > report_length
if [[ -z `tr -d '\0' < report_desc` ]]; then
    cat $kb_report_desc > report_desc
fi
rm $kb_report_desc
# Create mouse function
cd "${CONFIG_ROOT}/${M_FUNC_PATH}"
[ `cat subclass` == 0 ] && echo $M_SUBCLASS > subclass
[ `cat protocol` == 0 ] && echo $M_PROTO > protocol
[ `cat report_length` == 0 ] && echo $M_REPORT_LEN > report_length
if [[ -z `tr -d '\0' < report_desc` ]]; then
    cat $m_report_desc > report_desc
fi
rm $m_report_desc
# Link the functions to configuration
ms_func_link="${CONFIG_ROOT}/${C1_PATH}/$(basename "$MS_FUNC_PATH")"
if [ ! -L $ms_func_link ] && [ ! -d $ms_func_link ]; then
    rm -f $ms_func_link
fi
if [ ! -d $ms_func_link ]; then
    ln -s "${CONFIG_ROOT}/${MS_FUNC_PATH}" $ms_func_link
fi
kb_func_link="${CONFIG_ROOT}/${C1_PATH}/$(basename "$KB_FUNC_PATH")"
if [ ! -L $kb_func_link ] && [ ! -d $kb_func_link ]; then
    rm -f $kb_func_link
fi
if [ ! -d $kb_func_link ]; then
    ln -s "${CONFIG_ROOT}/${KB_FUNC_PATH}" $kb_func_link
fi
m_func_link="${CONFIG_ROOT}/${C1_PATH}/$(basename "$M_FUNC_PATH")"
if [ ! -L $m_func_link ] && [ ! -d $m_func_link ]; then
    rm -f $m_func_link
fi
if [ ! -d $m_func_link ]; then
    ln -s "${CONFIG_ROOT}/${M_FUNC_PATH}" $m_func_link
fi
# Enable the device
cd $CONFIG_ROOT
otg_udc=(/sys/class/udc/*)
if [ "${otg_udc[0]##*/}" != "`cat UDC`" ]; then
    echo ${otg_udc[0]##*/} > UDC
fi
exit 0
