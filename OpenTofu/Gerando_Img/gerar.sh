#!/bin/bash

# Variáveis globais fixas
IMAGE_NAME="debian-12-backports-genericcloud-amd64-daily.qcow2"
VOLUME_NAME="local-lvm"
SSHD_CONFIG_FILE="sshd_config"  # Caminho do arquivo local do sshd_config
PUBLIC_KEY_FILE="id_rsa.pub"    # Caminho do arquivo local da chave pública
PRIVATE_KEY_FILE="id_rsa"       # Caminho do arquivo local da chave privada
SCRIPT_FILE="update.sh"         # Nome do arquivo de script a ser executado

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

  # Instalação do qemu-guest-agent, SSH, configuração do sshd_config e cópia das chaves SSH
  echo "Instalando qemu-guest-agent, SSH e copiando configuração sshd_config e chaves SSH na imagem..."
  virt-customize -a "$IMAGE_NAME" --install qemu-guest-agent,openssh-server || error_exit "Falha ao instalar qemu-guest-agent e SSH."
  virt-customize -a "$IMAGE_NAME" --copy-in "$SSHD_CONFIG_FILE":/etc/ssh || error_exit "Falha ao copiar sshd_config."

  # Criação do diretório ~/.ssh
  virt-customize -a "$IMAGE_NAME" --run-command 'mkdir -p /root/.ssh && chmod 700 /root/.ssh' || error_exit "Falha ao criar diretório ~/.ssh."

  # Criação do diretório /home/notroot/.ssh/
  virt-customize -a "$IMAGE_NAME" --run-command 'mkdir -p /home/notroot/.ssh/ && chmod 700 /home/notroot/.ssh/' || error_exit "Falha ao criar diretório /home/notroot/.ssh/"

  # Cópia das chaves pública e privada - /root/.ssh/
  virt-customize -a "$IMAGE_NAME" --copy-in "$PUBLIC_KEY_FILE":/root/.ssh/ || error_exit "Falha ao copiar chave pública."
  virt-customize -a "$IMAGE_NAME" --copy-in "$PRIVATE_KEY_FILE":/root/.ssh/ || error_exit "Falha ao copiar chave privada."

    # Ajuste de permissões das chaves - /root/.ssh/
    virt-customize -a "$IMAGE_NAME" --run-command 'chmod 600 /root/.ssh/id_rsa' || error_exit "Falha ao ajustar permissões das chaves SSH."
    virt-customize -a "$IMAGE_NAME" --run-command 'chmod 644 /root/.ssh/id_rsa.pub' || error_exit "Falha ao ajustar permissões das chaves SSH."

  # Cópia das chaves pública e privada - /home/notroot/.ssh/
  virt-customize -a "$IMAGE_NAME" --copy-in "$PUBLIC_KEY_FILE":/home/notroot/.ssh/ || error_exit "Falha ao copiar chave pública."
  virt-customize -a "$IMAGE_NAME" --copy-in "$PRIVATE_KEY_FILE":/home/notroot/.ssh/ || error_exit "Falha ao copiar chave privada."

    # Ajuste de permissões das chaves - /home/notroot/.ssh/
    virt-customize -a "$IMAGE_NAME" --run-command 'chmod 600 /home/notroot/.ssh/id_rsa' || error_exit "Falha ao ajustar permissões das chaves SSH."
    virt-customize -a "$IMAGE_NAME" --run-command 'chmod 644 /home/notroot/.ssh/id_rsa.pub' || error_exit "Falha ao ajustar permissões das chaves SSH."

  # Copiar o script para a imagem
  virt-customize -a "$IMAGE_NAME" --copy-in "$SCRIPT_FILE":/usr/local/bin/ || error_exit "Falha ao copiar o script."

  # Tornar o script executável
  virt-customize -a "$IMAGE_NAME" --run-command "chmod +x /usr/local/bin/$SCRIPT_FILE" || error_exit "Falha ao tornar o script executável."

  # Criar o arquivo de serviço systemd
  virt-customize -a "$IMAGE_NAME" --run-command "echo -e '[Unit]\nDescription=Executar script customizado no boot\n\n[Service]\nType=simple\nExecStart=/usr/local/bin/$SCRIPT_FILE\n\n[Install]\nWantedBy=multi-user.target' > /etc/systemd/system/custom-script.service" || error_exit "Falha ao criar o arquivo de serviço systemd."

  # Habilitar o serviço para iniciar no boot
  virt-customize -a "$IMAGE_NAME" --run-command 'systemctl enable custom-script.service' || error_exit "Falha ao habilitar o serviço no systemd."

  # Criação da VM no Proxmox
  qm create "$VM_ID" --name "$TEMPLATE_NAME" --memory "$MEMORY" --cores "$CORES" --net0 virtio,bridge=vmbr0 || error_exit "Falha ao criar VM."
  qm importdisk "$VM_ID" "$IMAGE_NAME" "$VOLUME_NAME" || error_exit "Falha ao importar disco."
  qm set "$VM_ID" --scsihw virtio-scsi-single --scsi0 "$VOLUME_NAME:vm-$VM_ID-disk-0" || error_exit "Falha ao configurar o SCSI."
  qm set "$VM_ID" --agent enabled=1,fstrim_cloned_disks=1 || error_exit "Falha ao configurar o agente."

  # Configuração do Cloud-Init Disk, boot e vídeo padrão
  qm set "$VM_ID" --ide2 "$VOLUME_NAME:cloudinit" || error_exit "Falha ao configurar Cloud-Init."
  qm set "$VM_ID" --boot c --bootdisk scsi0 || error_exit "Falha ao configurar o boot."
  qm set "$VM_ID" --serial0 socket --vga std || error_exit "Falha ao configurar VGA padrão."

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