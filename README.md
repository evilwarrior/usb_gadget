# usb_gadget
## OTG Mode selection
Dual-role controllers can be forced into 'host' mode or 'peripheral' mode via the device-tree 'dr_mode' property.<br/><br/>
For example to force an IMX6 OTG controller to peripheral mode add 'dr_mode = "peripheral"
```
&usbotg {
        vbus-supply = <&reg_5p0v>;
        pinctrl-names = "default";
        pinctrl-0 = <&pinctrl_usbotg>;
        disable-over-current;
        dr_mode = "peripheral";
        status = "okay";
};
```
This can be done in the bootloader, here's an example for GW54xx:  
```
setenv fixfdt 'fdt addr ${fdt_addr}; fdt resize; fdt set /soc/aips-bus@2100000/usb@2184000 dr_mode gadget'
saveenv #once you have made your selection
```
Additionally some host controllers such as the Chips and Media controller used on the IMX6 have hooks that allow them to be configured at runtime in Linux Userspace.<br/><br/>
For example on IMX6 boards:
```
echo gadget > /sys/kernel/debug/ci_hdrc.0/role
```
## Using a Non-OTG port in device mode 
In some cases you can use a USB Type-A socket in device mode in a non-standard way. (For example Phicomm N1)<br/><br/>
In this case you can do the following:
1. use a non-standard Type-A plug to Type-A plug cable and isolate the VBUS (red wire) to ensure host and device are not both driving VBUS
2. configure the OTG controller for device-mode (see above)
3. Load a gadget driver (modprobe g_* or use configfs)
