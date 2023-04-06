#!/bin/bash

# exibe o menu
echo "Selecione uma opção:"
echo "1 - Criar imagem Debian"
echo "2 - Criar imagem Ubuntu"
read opcao

# verifica a opção selecionada
case $opcao in
  1)
    imageURL=https://cloud.debian.org/images/cloud/bullseye-backports/daily/20230406-1342/debian-11-backports-genericcloud-amd64-daily-20230406-1342.qcow2
    imageName="debian-11-backports-genericcloud-amd64-daily-20230406-1342.qcow2"
    volumeName="local-lvm"
    virtualMachineId="300"
    templateName="Debian11CloudInit"
    tmp_cores="2"
    tmp_memory="3500"
    ;;
  2)
    imageURL=https://cloud-images.ubuntu.com/lunar/current/lunar-server-cloudimg-amd64.img
    imageName="lunar-server-cloudimg-amd64.img"
    volumeName="local-lvm"
    virtualMachineId="301"
    templateName="UbuntuLunarCloudInit"
    tmp_cores="2"
    tmp_memory="3500"
    ;;
  *)
    echo "Opção inválida"
    exit 1
    ;;
esac

# Baixando a imagem
rm *.img                        # Apagando todas as imagens *.img
wget -O $imageName $imageURL    # Baixando a imagem escolhida
qm destroy $virtualMachineId    # Garantindo que não irá existir uma máquina com o mesmo ID (Apagando)

virt-customize -a $imageName --install qemu-guest-agent

qm create $virtualMachineId --name $templateName --memory $tmp_memory --cores $tmp_cores --net0 virtio,bridge=vmbr0
qm importdisk $virtualMachineId $imageName $volumeName
qm set $virtualMachineId --scsihw virtio-scsi-pci --scsi0 $volumeName:vm-$virtualMachineId-disk-0
qm set $virtualMachineId --boot c --bootdisk scsi0
qm set $virtualMachineId --ide2 $volumeName:cloudinit
qm set $virtualMachineId --serial0 socket --vga serial0
qm template $virtualMachineId