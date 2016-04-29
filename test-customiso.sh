#!/bin/sh

while [ $# -gt 0 ]; do
    case "$1" in
    --cleanup-only)
        CLEANUP_ONLY=yes
        shift ;;
    -*) USAGE=yes
        echo "'$1': invalid option"
        shift ;;
    *) break ;;
    esac
done
if [ $# -ne 0 ]; then
    USAGE=yes
fi
if [ -n "$USAGE" ];then
    echo "usage: $0"
    exit 1
fi

virsh destroy customiso > /dev/null 2>&1
virsh undefine customiso > /dev/null 2>&1
virsh vol-delete --pool default customiso.img > /dev/null 2>&1

if [ -n "$CLEANUP_ONLY" ]; then
    exit 0
fi

CUSTOM_BOOTISO="$(pwd)/custom-boot.iso"
cat <<_EOF_ > /tmp/test-customiso.xml
<domain type='kvm'>
  <name>customiso</name>
  <memory>524288</memory>
  <currentMemory>524288</currentMemory>
  <vcpu>1</vcpu>
  <os>
    <type arch='x86_64' machine='pc-1.0-qemu-kvm'>hvm</type>
    <boot dev='cdrom'/>
    <boot dev='hd'/>
    <bootmenu enable='yes'/>
  </os>
  <features>
    <acpi/>
    <apic/>
    <pae/>
  </features>
  <clock offset='utc'/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>restart</on_crash>
  <devices>
    <emulator>/usr/bin/kvm</emulator>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='/var/lib/libvirt/images/customiso.img'/>
      <target dev='hda' bus='ide'/>
      <address type='drive' controller='0' bus='0' unit='0'/>
    </disk>
    <disk type='file' device='cdrom'>
      <driver name='qemu' type='raw'/>
      <source file='$CUSTOM_BOOTISO'/>
      <target dev='hdc' bus='ide'/>
      <readonly/>
      <address type='drive' controller='0' bus='1' unit='0'/>
    </disk>
    <controller type='ide' index='0'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x1'/>
    </controller>
    <interface type='network'>
      <mac address='52:54:00:00:00:04'/>
      <source network='default'/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
    </interface>
    <serial type='pty'>
      <target port='0'/>
    </serial>
    <console type='pty'>
      <target type='serial' port='0'/>
    </console>
    <memballoon model='virtio'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x0'/>
    </memballoon>
  </devices>
</domain>
_EOF_

virsh vol-create-as default customiso.img 10G --format qcow2
virsh define /tmp/test-customiso.xml
exec virsh start customiso --console
