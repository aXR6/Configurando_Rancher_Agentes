#!/bin/bash

# Variáveis globais fixas
IMAGE_NAME="debian-12-backports-nocloud-amd64-daily.qcow2"
VOLUME_NAME="local-lvm"

# Função para exibir mensagens de erro e sair
error_exit() {
  echo "Erro: $1" >&2
  exit 1
}

# Função para instalação das dependências
install_dependencies() {
  echo "Verificando e instalando dependências..."
  if ! dpkg -s libguestfs-tools &> /dev/null; then
    apt update || error_exit "Falha ao atualizar pacotes."
    apt install -y libguestfs-tools || error_exit "Falha ao instalar libguestfs-tools."
  fi
}

# Função para configurar os parâmetros da imagem
configure_image_params() {
  case $1 in
    1)
      VM_ID="303"
      TEMPLATE_NAME="Debian12CloudInitRancher"
      CORES="2"
      MEMORY="3500"
      ;;
    2)
      VM_ID="304"
      TEMPLATE_NAME="Debian12CloudInitAgente"
      CORES="2"
      MEMORY="3500"
      ;;
    3)
      VM_ID="305"
      TEMPLATE_NAME="Debian12CloudInitComum"
      CORES="2"
      MEMORY="3500"
      ;;
    *)
      error_exit "Opção inválida"
      ;;
  esac
}

# Função para criar o template no Proxmox
create_template() {
  echo "Criando template $TEMPLATE_NAME com ID $VM_ID..."

  # Remoção de uma possível VM com o mesmo ID
  qm destroy "$VM_ID" --purge &> /dev/null || echo "Nenhuma VM com ID $VM_ID encontrada para remover."

  # Instalação do qemu-guest-agent
  echo "Instalando qemu-guest-agent na imagem..."
  virt-customize -a "$IMAGE_NAME" --install qemu-guest-agent || error_exit "Falha ao instalar o qemu-guest-agent."

  # Criação da VM no Proxmox
  qm create "$VM_ID" --name "$TEMPLATE_NAME" --memory "$MEMORY" --cores "$CORES" --net0 virtio,bridge=vmbr0 || error_exit "Falha ao criar VM."
  qm importdisk "$VM_ID" "$IMAGE_NAME" "$VOLUME_NAME" || error_exit "Falha ao importar disco."
  qm set "$VM_ID" --scsihw virtio-scsi-single --scsi0 "$VOLUME_NAME:vm-$VM_ID-disk-0" || error_exit "Falha ao configurar o SCSI."
  qm set "$VM_ID" --agent enabled=1,fstrim_cloned_disks=1 || error_exit "Falha ao configurar o agente."

  # Configuração do Cloud-Init Disk e boot
  qm set "$VM_ID" --ide2 "$VOLUME_NAME:cloudinit" || error_exit "Falha ao configurar Cloud-Init."
  qm set "$VM_ID" --boot c --bootdisk scsi0 || error_exit "Falha ao configurar o boot."
  qm set "$VM_ID" --serial0 socket --vga serial0 || error_exit "Falha ao configurar VGA."

  # Convertendo para template
  qm template "$VM_ID" || error_exit "Falha ao converter para template."

  echo "Template $TEMPLATE_NAME criado com sucesso."
}

# Função principal
main() {
  install_dependencies

  # Menu de opções
  echo "Selecione uma opção:"
  echo "1 - Criar imagem do Rancher"
  echo "2 - Criar imagem do Agente"
  echo "3 - Criar imagem do Comum"
  read -r opcao

  # Configurar parâmetros
  configure_image_params "$opcao"

  # Criar template
  create_template
}

# Execução do script
main