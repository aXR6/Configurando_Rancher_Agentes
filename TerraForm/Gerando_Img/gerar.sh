#!/bin/bash

# Instalação das dependências
#apt update
#apt install -y libguestfs-tools

# Menu de opções
echo "Selecione uma opção:"
echo "1 - Criar imagem do Rancher"
echo "2 - Criar imagem do Agente"
echo "3 - Criar imagem do Comum"
read opcao

# Verifica a opção selecionada
case $opcao in
  1)
    #imageURL="https://download937.mediafire.com/fbmvqmmb0yugg03MlvpVfbKfQ4Wf7c1E2hcf1SoMusTozKGni0eTKwmlyfRRb_wEc7YASbRA0ekNS6trxw49AR8C58AHFGPP/sgnuk7dh1fva4pn/debian-11-backports-genericcloud-amd64-daily.qcow2"
    imageName="debian-11-backports-genericcloud-amd64-daily.qcow2"
    volumeName="local-zfs"
    virtualMachineId="303"
    templateName="Debian11CloudInitRancher"
    tmp_cores="2"
    tmp_memory="3500"
    ;;
  2)
    #imageURL="https://download937.mediafire.com/fbmvqmmb0yugg03MlvpVfbKfQ4Wf7c1E2hcf1SoMusTozKGni0eTKwmlyfRRb_wEc7YASbRA0ekNS6trxw49AR8C58AHFGPP/sgnuk7dh1fva4pn/debian-11-backports-genericcloud-amd64-daily.qcow2"
    imageName="debian-11-backports-genericcloud-amd64-daily.qcow2"
    volumeName="local-zfs"
    virtualMachineId="304"
    templateName="Debian11CloudInitAgente"
    tmp_cores="2"
    tmp_memory="3500"
    ;;
  3)
    #imageURL="https://download937.mediafire.com/fbmvqmmb0yugg03MlvpVfbKfQ4Wf7c1E2hcf1SoMusTozKGni0eTKwmlyfRRb_wEc7YASbRA0ekNS6trxw49AR8C58AHFGPP/sgnuk7dh1fva4pn/debian-11-backports-genericcloud-amd64-daily.qcow2"
    imageName="debian-11-backports-genericcloud-amd64-daily.qcow2"
    volumeName="local-zfs"
    virtualMachineId="305"
    templateName="Debian11CloudInitComum"
    tmp_cores="2"
    tmp_memory="3500"
    ;;
  *)
    echo "Opção inválida"
    exit 1
    ;;
esac

# Remoção de imagens
rm *.img

# Download da imagem
#wget -O "$imageName" "$imageURL"

# Remoção de uma possível máquina com o mesmo ID
qm destroy "$virtualMachineId"

# Instalação do qemu-guest-agent
virt-customize -a "$imageName" --install qemu-guest-agent

# Criação da imagem Proxmox VM a partir do Debian 11 Cloud Image
qm create "$virtualMachineId" --name "$templateName" --memory "$tmp_memory" --cores "$tmp_cores" --net0 virtio,bridge=vmbr0
qm importdisk "$virtualMachineId" "$imageName" "$volumeName"
qm set "$virtualMachineId" --scsihw virtio-scsi-single --scsi0 "$volumeName:vm-$virtualMachineId-disk-0"
qm set "$virtualMachineId" --agent enabled=1,fstrim_cloned_disks=1

# Criação do Cloud-Init Disk e configuração do boot
qm set "$virtualMachineId" --ide2 "$volumeName:cloudinit"
qm set "$virtualMachineId" --boot c --bootdisk scsi0
qm set "$virtualMachineId" --serial0 socket --vga serial0
qm template "$virtualMachineId"