{ pkgs, writeShellScriptBin }:

writeShellScriptBin "kat-vm" ''
  ${pkgs.qemu_full}/bin/qemu-system-x86_64 -name guest=win10,debug-threads=on \
  -object secret,id=masterKey0,format=raw,file=${
    ../../private/files/vm/master-key.aes
  } \
  -blockdev '{"driver":"file","filename":"/home/kat/projects/nixfiles/private/files/vm/OVMF_CODE.fd","node-name":"libvirt-pflash0-storage","auto-read-only":true,"discard":"unmap"}' \
  -blockdev '{"node-name":"libvirt-pflash0-format","read-only":true,"driver":"raw","file":"libvirt-pflash0-storage"}' \
  -blockdev '{"driver":"file","filename":"/home/kat/projects/nixfiles/private/files/vm/win10_VARS.fd","node-name":"libvirt-pflash1-storage","auto-read-only":true,"discard":"unmap"}' \
  -blockdev '{"node-name":"libvirt-pflash1-format","read-only":false,"driver":"raw","file":"libvirt-pflash1-storage"}' \
  -machine pc-q35-5.1,accel=kvm,usb=off,vmport=off,dump-guest-core=off,pflash0=libvirt-pflash0-format,pflash1=libvirt-pflash1-format,memory-backend=pc.ram \
   -monitor stdio \
   -cpu host,migratable=on,topoext=on,hv-time,hv-relaxed,hv-vapic,hv-spinlocks=0x1fff,host-cache-info=on,l3-cache=off -m 12288 \
   -object memory-backend-ram,id=pc.ram,size=12884901888 -overcommit mem-lock=off -smp 6,sockets=1,dies=1,cores=3,threads=2 \
   -object iothread,id=iothread1 -uuid 96052919-6a83-4e9f-8e9b-628de3e27cc1 \
   -display none \
   -no-user-config \
   -nodefaults \
   -rtc base=localtime,driftfix=slew -global kvm-pit.lost_tick_policy=delay \
   -no-hpet -no-shutdown \
   -global ICH9-LPC.disable_s3=1 \
   -global ICH9-LPC.disable_s4=1 \
   -boot strict=on \
   -device pcie-root-port,port=0x10,chassis=1,id=pci.1,bus=pcie.0,multifunction=on,addr=0x2 \
   -device pcie-root-port,port=0x11,chassis=2,id=pci.2,bus=pcie.0,addr=0x2.0x1 -device pcie-root-port,port=0x12,chassis=3,id=pci.3,bus=pcie.0,addr=0x2.0x2 \
   -device pcie-root-port,port=0x13,chassis=4,id=pci.4,bus=pcie.0,addr=0x2.0x3 -device pcie-root-port,port=0x14,chassis=5,id=pci.5,bus=pcie.0,addr=0x2.0x4 \
   -device pcie-root-port,port=0x15,chassis=6,id=pci.6,bus=pcie.0,addr=0x2.0x5 -device pcie-root-port,port=0x16,chassis=7,id=pci.7,bus=pcie.0,addr=0x2.0x6 \
   -device pcie-pci-bridge,id=pci.8,bus=pci.4,addr=0x0 \
   -device pcie-root-port,port=0x17,chassis=9,id=pci.9,bus=pcie.0,addr=0x2.0x7 \
   -device pcie-root-port,port=0x8,chassis=10,id=pci.10,bus=pcie.0,multifunction=on,addr=0x1 \
   -device pcie-root-port,port=0x9,chassis=11,id=pci.11,bus=pcie.0,addr=0x1.0x1 \
   -device pcie-root-port,port=0xa,chassis=12,id=pci.12,bus=pcie.0,addr=0x1.0x2 \
   -device pcie-root-port,port=0xb,chassis=13,id=pci.13,bus=pcie.0,addr=0x1.0x3 \
   -device pcie-root-port,port=0xc,chassis=14,id=pci.14,bus=pcie.0,addr=0x1.0x4 \
   -device pcie-root-port,port=0xd,chassis=15,id=pci.15,bus=pcie.0,addr=0x1.0x5 \
   -device pcie-root-port,port=0xe,chassis=16,id=pci.16,bus=pcie.0,addr=0x1.0x6 \
   -device pcie-root-port,port=0xf,chassis=17,id=pci.17,bus=pcie.0,addr=0x1.0x7 \
   -device pcie-root-port,port=0x18,chassis=18,id=pci.18,bus=pcie.0,multifunction=on,addr=0x3 \
   -device pcie-root-port,port=0x19,chassis=19,id=pci.19,bus=pcie.0,addr=0x3.0x1 \
   -device pcie-root-port,port=0x1a,chassis=20,id=pci.20,bus=pcie.0,addr=0x3.0x2 \
   -device pcie-root-port,port=0x1b,chassis=21,id=pci.21,bus=pcie.0,addr=0x3.0x3 \
   -device pcie-root-port,port=0x1c,chassis=22,id=pci.22,bus=pcie.0,addr=0x3.0x4 \
   -device pcie-root-port,port=0x1d,chassis=23,id=pci.23,bus=pcie.0,multifunction=on,addr=0x3.0x5 \
   -device pcie-pci-bridge,id=pci.24,bus=pci.10,addr=0x0 \
   -device ich9-usb-ehci1,id=usb -device ich9-usb-uhci1,masterbus=usb.0,firstport=0,multifunction=on -device ich9-usb-uhci2,masterbus=usb.0,firstport=2 -device ich9-usb-uhci3,masterbus=usb.0,firstport=4 \
   -device virtio-scsi-pci,id=scsi0,bus=pci.6,addr=0x0 \
   -device virtio-serial-pci,id=virtio-serial0,bus=pci.3,addr=0x0 \
   -blockdev '{"driver":"file","filename":"/dev/disk/by-id/ata-HFS256G32TNF-N3A0A_MJ8BN15091150BM1Z","node-name":"libvirt-2-storage","auto-read-only":true,"discard":"unmap"}' \
   -blockdev '{"node-name":"libvirt-2-format","read-only":false,"discard":"unmap","driver":"raw","file":"libvirt-2-storage"}' \
   -device scsi-hd,bus=scsi0.0,channel=0,scsi-id=0,lun=0,device_id=drive-scsi0-0-0-0,drive=libvirt-2-format,id=scsi0-0-0-0,bootindex=2 \
   -blockdev '{"driver":"host_device","filename":"/dev/disk/by-id/ata-TOSHIBA_HDWD130_787VUS4AS-part2","aio":"native","node-name":"libvirt-1-storage","cache":{"direct":true,"no-flush":false},"auto-read-only":true,"discard":"unmap"}' \
   -blockdev '{"node-name":"libvirt-1-format","read-only":false,"cache":{"direct":true,"no-flush":false},"driver":"raw","file":"libvirt-1-storage"}' \
   -netdev user,id=natnet0,net=10.1.3.0/24,host=10.1.3.1 -device e1000-82545em,netdev=natnet0,id=net2 \
   -device vfio-pci,host=0000:26:00.0,id=hostdev0,bus=pci.7,addr=0x0,romfile=${
     ./vbios.rom
   } \
   -device vfio-pci,host=0000:26:00.1,id=hostdev1,bus=pci.9,addr=0x0 \
   -device virtio-balloon-pci,id=balloon0,bus=pci.5,addr=0x0 \
   -chardev socket,path=/tmp/vfio-qmp,server,nowait,id=qmp0 \
   -mon chardev=qmp0,id=qmp,mode=control \
   -chardev socket,path=/tmp/vfio-qga,server,nowait,id=qga0 \
   -device virtserialport,chardev=qga0,name=org.qemu.guest_agent.0 \
   -set device.scsi0-0-0-0.rotation_rate=1 \
   -cpu host,hv_time,kvm=off,hv_vendor_id=null,-hypervisor \
   -msg timestamp=on
    ''