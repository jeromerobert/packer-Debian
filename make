#! /bin/sh -ex

cloud-init schema --config-file user-data
cloud-init schema -t network-config --config-file network-config
# https://andreafortuna.org/2019/10/24/how-to-create-a-virtualbox-vm-from-command-line/
# https://superuser.com/questions/827977/use-cloud-init-with-virtualbox
# https://cloud.debian.org/images/cloud/
# https://cloudinit.readthedocs.io/en/latest/reference/datasources/nocloud.html#source-files
genisoimage -output cloud-init.iso -volid cidata -joliet -r meta-data user-data vendor-data network-config
img_date=20240902-1858
img_file=debian-13-generic-amd64-daily-$img_date
vm_name="Debian 13"
[ -f $img_file.qcow2 ] || curl -L -O https://cloud.debian.org/images/cloud/trixie/daily/$img_date/$img_file.qcow2
VBoxManage unregistervm "$vm_name" --delete-all || true
VBoxManage closemedium disk $img_file.vdi || true
VBoxManage closemedium disk home.vdi --delete || true
VBoxManage closemedium disk tmp.vdi --delete || true
[ -f $img_file.vdi ] || qemu-img convert -O vdi $img_file.qcow2 $img_file.vdi
VBoxManage modifyhd $img_file.vdi --resize 8000
VBoxManage closemedium disk $img_file.vdi
VBoxManage createhd --filename home.vdi --size 2048 --format VDI
VBoxManage createhd --filename tmp.vdi --size 2048 --format VDI
VBoxManage createvm --name "$vm_name" --ostype Debian_64 --register --basefolder $PWD
hostonly=$(VBoxManage list hostonlyifs | awk '/^Name:/ {print $2}')
VBoxManage modifyvm "$vm_name" --memory 2048 --graphicscontroller vmsvga --clipboard bidirectional --vram 16 --nic2 hostonly --hostonlyadapter2 $hostonly
VBoxManage storagectl "$vm_name" --name SATA --add sata --controller IntelAhci --portcount=3 --hostiocache off
VBoxManage storageattach "$vm_name" --storagectl SATA --port 0 --device 0 --type hdd --medium  $PWD/$img_file.vdi
VBoxManage storageattach "$vm_name" --storagectl SATA --port 1 --type hdd --medium home.vdi
VBoxManage storageattach "$vm_name" --storagectl SATA --port 2 --type hdd --medium tmp.vdi
VBoxManage storagectl "$vm_name" --name IDE --add ide --controller PIIX4
VBoxManage storageattach "$vm_name" --storagectl IDE --port 1 --device 0 --type dvddrive --medium $PWD/cloud-init.iso
VirtualBoxVM --startvm "$vm_name"
# TODO
# * Fix environment variables (/etc/profile is not parsed)