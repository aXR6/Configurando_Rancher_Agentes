#!/bin/bash

# Variáveis globais fixas
IMAGE_NAME="debian-12-backports-genericcloud-amd64-daily.qcow2"
VOLUME_NAME="local-lvm"
SSHD_CONFIG_FILE="sshd_config"      # Caminho do arquivo local do sshd_config
PUBLIC_KEY_FILE="id_rsa.pub"        # Caminho do arquivo local da chave pública
PRIVATE_KEY_FILE="id_rsa"           # Caminho do arquivo local da chave privada

SCRIPT_FILE_rancher="rancher.sh"    # Nome do arquivo de script a ser executado
SCRIPT_FILE_agentes="agentes.sh"    # Nome do arquivo de script a ser executado
SCRIPT_FILE="comum.sh"              # Nome do arquivo de script a ser executado
SCRIPT_FILE_dns="dns.sh"            # Nome do arquivo de script a ser executado
SCRIPT_FILE_nfs="nfs.sh"            # Nome do arquivo de script a ser executado

Dir_dnsns1="/home/img/dnsns1"
Dir_dnsns2="/home/img/dnsns2"


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
      VM_ID="300"
      TEMPLATE_NAME="Debian12CloudInitRancher"
      CORES="1"
      MEMORY="1024"
      ;;
    2)
      VM_ID="301"
      TEMPLATE_NAME="Debian12CloudInitAgente"
      CORES="1"
      MEMORY="1024"
      ;;
    3)
      VM_ID="302"
      TEMPLATE_NAME="Debian12CloudInitComum"
      CORES="1"
      MEMORY="1024"
      ;;
    4)
      VM_ID="303"
      TEMPLATE_NAME="Debian12CloudInitDNS1"
      CORES="2"
      MEMORY="1024"
      ;;
    5)
      VM_ID="304"
      TEMPLATE_NAME="Debian12CloudInitDNS2"
      CORES="1"
      MEMORY="1024"
      ;;
    6)
      VM_ID="305"
      TEMPLATE_NAME="Debian12CloudInitNFS"
      CORES="1"
      MEMORY="1024"
      ;;
    *)
      error_exit "Opção inválida"
      ;;
  esac
}

# Função VM RANCHER
# Função para criar o template no Proxmox
create_template_rancher() {
  echo "Criando template $TEMPLATE_NAME com ID $VM_ID..."

  echo "Remoção de uma possível VM com o mesmo ID"
  qm destroy "$VM_ID" --purge &> /dev/null || echo "Nenhuma VM com ID $VM_ID encontrada para remover."

  # Instalação do qemu-guest-agent, SSH, configuração do sshd_config e cópia das chaves SSH
  echo "Instalando qemu-guest-agent, SSH e copiando configuração sshd_config e chaves SSH na imagem..."
  virt-customize -a "$IMAGE_NAME" --install qemu-guest-agent,openssh-server,curl,sudo || error_exit "Falha ao instalar qemu-guest-agent e SSH."
  virt-customize -a "$IMAGE_NAME" --copy-in "$SSHD_CONFIG_FILE":/etc/ssh || error_exit "Falha ao copiar sshd_config."

  echo "Criação do diretório ~/.ssh"
  virt-customize -a "$IMAGE_NAME" --run-command 'mkdir -p /root/.ssh && chmod 700 /root/.ssh' || error_exit "Falha ao criar diretório ~/.ssh."

  echo "Criação do diretório /home/notroot/.ssh/"
  virt-customize -a "$IMAGE_NAME" --run-command 'mkdir -p /home/notroot/.ssh/ && chmod 700 /home/notroot/.ssh/' || error_exit "Falha ao criar diretório /home/notroot/.ssh/"

  echo "Cópia das chaves pública e privada - /root/.ssh/"
  virt-customize -a "$IMAGE_NAME" --copy-in "$PUBLIC_KEY_FILE":/root/.ssh/ || error_exit "Falha ao copiar chave pública."
  virt-customize -a "$IMAGE_NAME" --copy-in "$PRIVATE_KEY_FILE":/root/.ssh/ || error_exit "Falha ao copiar chave privada."

    echo "Ajuste de permissões das chaves - /root/.ssh/"
    virt-customize -a "$IMAGE_NAME" --run-command 'chmod 600 /root/.ssh/id_rsa' || error_exit "Falha ao ajustar permissões das chaves SSH."
    virt-customize -a "$IMAGE_NAME" --run-command 'chmod 644 /root/.ssh/id_rsa.pub' || error_exit "Falha ao ajustar permissões das chaves SSH."

  echo "Cópia das chaves pública e privada - /home/notroot/.ssh/"
  virt-customize -a "$IMAGE_NAME" --copy-in "$PUBLIC_KEY_FILE":/home/notroot/.ssh/ || error_exit "Falha ao copiar chave pública."
  virt-customize -a "$IMAGE_NAME" --copy-in "$PRIVATE_KEY_FILE":/home/notroot/.ssh/ || error_exit "Falha ao copiar chave privada."

    echo "Ajuste de permissões das chaves - /home/notroot/.ssh/"
    virt-customize -a "$IMAGE_NAME" --run-command 'chmod 600 /home/notroot/.ssh/id_rsa' || error_exit "Falha ao ajustar permissões das chaves SSH."
    virt-customize -a "$IMAGE_NAME" --run-command 'chmod 644 /home/notroot/.ssh/id_rsa.pub' || error_exit "Falha ao ajustar permissões das chaves SSH."

  echo "Copiar o script para a imagem"
  virt-customize -a "$IMAGE_NAME" --copy-in "$SCRIPT_FILE_rancher":/usr/local/bin/ || error_exit "Falha ao copiar o script."

  echo "Tornar o script executável"
  virt-customize -a "$IMAGE_NAME" --run-command "chmod +x /usr/local/bin/$SCRIPT_FILE_rancher" || error_exit "Falha ao tornar o script executável."

  echo "Criar o arquivo de serviço systemd"
  virt-customize -a "$IMAGE_NAME" --run-command "echo -e '[Unit]\nDescription=Executar script customizado no boot\n\n[Service]\nType=simple\nExecStart=/usr/local/bin/$SCRIPT_FILE\n\n[Install]\nWantedBy=multi-user.target' > /etc/systemd/system/custom-script.service" || error_exit "Falha ao criar o arquivo de serviço systemd."

  echo "Habilitar o serviço para iniciar no boot"
  virt-customize -a "$IMAGE_NAME" --run-command 'systemctl enable custom-script.service' || error_exit "Falha ao habilitar o serviço no systemd."

  echo "Instalando o Docker na sua versão 27.2"
  virt-customize -a "$IMAGE_NAME" --run-command 'curl https://releases.rancher.com/install-docker/27.2.sh | sh && apt-mark hold docker-ce docker-ce-cli docker-ce-rootless-extras' || error_exit "Falha ao instalar o Docker e prender a versão."

  echo "Criação da VM no Proxmox"
  qm create "$VM_ID" --name "$TEMPLATE_NAME" --memory "$MEMORY" --cores "$CORES" --net0 virtio,bridge=vmbr0 || error_exit "Falha ao criar VM."
  qm importdisk "$VM_ID" "$IMAGE_NAME" "$VOLUME_NAME" || error_exit "Falha ao importar disco."
  qm set "$VM_ID" --scsihw virtio-scsi-single --scsi0 "$VOLUME_NAME:vm-$VM_ID-disk-0" || error_exit "Falha ao configurar o SCSI."
  qm set "$VM_ID" --agent enabled=1,fstrim_cloned_disks=1 || error_exit "Falha ao configurar o agente."

  echo "Configuração do Cloud-Init Disk, boot e vídeo padrão"
  qm set "$VM_ID" --ide2 "$VOLUME_NAME:cloudinit" || error_exit "Falha ao configurar Cloud-Init."
  qm set "$VM_ID" --boot c --bootdisk scsi0 || error_exit "Falha ao configurar o boot."
  qm set "$VM_ID" --serial0 socket --vga std || error_exit "Falha ao configurar VGA padrão."

  echo "Convertendo para template"
  qm template "$VM_ID" || error_exit "Falha ao converter para template."

  echo "Template $TEMPLATE_NAME criado com sucesso."
}

# Função VM AGENTES
# Função para criar o template no Proxmox
create_template_agentes() {
  echo "Criando template $TEMPLATE_NAME com ID $VM_ID..."

  echo "Remoção de uma possível VM com o mesmo ID"
  qm destroy "$VM_ID" --purge &> /dev/null || echo "Nenhuma VM com ID $VM_ID encontrada para remover."

  # Instalação do qemu-guest-agent, SSH, configuração do sshd_config e cópia das chaves SSH
  echo "Instalando qemu-guest-agent, SSH e copiando configuração sshd_config e chaves SSH na imagem..."
  virt-customize -a "$IMAGE_NAME" --install qemu-guest-agent,openssh-server || error_exit "Falha ao instalar qemu-guest-agent e SSH."
  virt-customize -a "$IMAGE_NAME" --copy-in "$SSHD_CONFIG_FILE":/etc/ssh || error_exit "Falha ao copiar sshd_config."

  echo "Criação do diretório ~/.ssh"
  virt-customize -a "$IMAGE_NAME" --run-command 'mkdir -p /root/.ssh && chmod 700 /root/.ssh' || error_exit "Falha ao criar diretório ~/.ssh."

  echo "Criação do diretório /home/notroot/.ssh/"
  virt-customize -a "$IMAGE_NAME" --run-command 'mkdir -p /home/notroot/.ssh/ && chmod 700 /home/notroot/.ssh/' || error_exit "Falha ao criar diretório /home/notroot/.ssh/"

  echo "Cópia das chaves pública e privada - /root/.ssh/"
  virt-customize -a "$IMAGE_NAME" --copy-in "$PUBLIC_KEY_FILE":/root/.ssh/ || error_exit "Falha ao copiar chave pública."
  virt-customize -a "$IMAGE_NAME" --copy-in "$PRIVATE_KEY_FILE":/root/.ssh/ || error_exit "Falha ao copiar chave privada."

  echo "Ajuste de permissões das chaves - /root/.ssh/"
  virt-customize -a "$IMAGE_NAME" --run-command 'chmod 600 /root/.ssh/id_rsa' || error_exit "Falha ao ajustar permissões das chaves SSH."
  virt-customize -a "$IMAGE_NAME" --run-command 'chmod 644 /root/.ssh/id_rsa.pub' || error_exit "Falha ao ajustar permissões das chaves SSH."

  echo "Cópia das chaves pública e privada - /home/notroot/.ssh/"
  virt-customize -a "$IMAGE_NAME" --copy-in "$PUBLIC_KEY_FILE":/home/notroot/.ssh/ || error_exit "Falha ao copiar chave pública."
  virt-customize -a "$IMAGE_NAME" --copy-in "$PRIVATE_KEY_FILE":/home/notroot/.ssh/ || error_exit "Falha ao copiar chave privada."

  echo "Ajuste de permissões das chaves - /home/notroot/.ssh/"
  virt-customize -a "$IMAGE_NAME" --run-command 'chmod 600 /home/notroot/.ssh/id_rsa' || error_exit "Falha ao ajustar permissões das chaves SSH."
  virt-customize -a "$IMAGE_NAME" --run-command 'chmod 644 /home/notroot/.ssh/id_rsa.pub' || error_exit "Falha ao ajustar permissões das chaves SSH."

  echo "Copiar o script para a imagem"
  virt-customize -a "$IMAGE_NAME" --copy-in "$SCRIPT_FILE_agentes":/usr/local/bin/ || error_exit "Falha ao copiar o script."

  echo "Tornar o script executável"
  virt-customize -a "$IMAGE_NAME" --run-command "chmod +x /usr/local/bin/$SCRIPT_FILE_agentes" || error_exit "Falha ao tornar o script executável."

  echo "Criar o arquivo de serviço systemd"
  virt-customize -a "$IMAGE_NAME" --run-command "echo -e '[Unit]\nDescription=Executar script customizado no boot\n\n[Service]\nType=simple\nExecStart=/usr/local/bin/$SCRIPT_FILE_agentes\n\n[Install]\nWantedBy=multi-user.target' > /etc/systemd/system/custom-script.service" || error_exit "Falha ao criar o arquivo de serviço systemd."

  echo "Habilitar o serviço para iniciar no boot"
  virt-customize -a "$IMAGE_NAME" --run-command 'systemctl enable custom-script.service' || error_exit "Falha ao habilitar o serviço no systemd."

  echo "Instalando o Docker na sua versão 27.2"
  virt-customize -a "$IMAGE_NAME" --run-command 'curl https://releases.rancher.com/install-docker/27.2.sh | sh && apt-mark hold docker-ce docker-ce-cli docker-ce-rootless-extras' || error_exit "Falha ao instalar o Docker e prender a versão."

  # Configuração do cliente NFS
  #echo "Configurando cliente NFS..."
  #virt-customize -a "$IMAGE_NAME" --install nfs-common || error_exit "Falha ao instalar o cliente NFS."

  #echo "Criando diretórios de montagem NFS..."
  #virt-customize -a "$IMAGE_NAME" --run-command 'mkdir -p /mnt/nfs/torrent /mnt/nfs/music && chmod 755 /mnt/nfs/torrent /mnt/nfs/music' || error_exit "Falha ao criar diretórios de montagem NFS."

  #echo "Configurando montagem NFS em /etc/fstab..."
  #virt-customize -a "$IMAGE_NAME" --run-command "echo '192.168.3.100:/srv/nfs/torrent /mnt/nfs/torrent nfs defaults 0 0' >> /etc/fstab" || error_exit "Falha ao configurar /etc/fstab para montagem de torrent."
  #virt-customize -a "$IMAGE_NAME" --run-command "echo '192.168.3.100:/srv/nfs/music /mnt/nfs/music nfs defaults 0 0' >> /etc/fstab" || error_exit "Falha ao configurar /etc/fstab para montagem de música."

  #echo "Montando os diretórios NFS..."
  #virt-customize -a "$IMAGE_NAME" --run-command 'mount -a' || error_exit "Falha ao montar os diretórios NFS."

  echo "Criação da VM no Proxmox"
  qm create "$VM_ID" --name "$TEMPLATE_NAME" --memory "$MEMORY" --cores "$CORES" --net0 virtio,bridge=vmbr0 || error_exit "Falha ao criar VM."
  qm importdisk "$VM_ID" "$IMAGE_NAME" "$VOLUME_NAME" || error_exit "Falha ao importar disco."
  qm set "$VM_ID" --scsihw virtio-scsi-single --scsi0 "$VOLUME_NAME:vm-$VM_ID-disk-0" || error_exit "Falha ao configurar o SCSI."
  qm set "$VM_ID" --agent enabled=1,fstrim_cloned_disks=1 || error_exit "Falha ao configurar o agente."

  echo "Configuração do Cloud-Init Disk, boot e vídeo padrão"
  qm set "$VM_ID" --ide2 "$VOLUME_NAME:cloudinit" || error_exit "Falha ao configurar Cloud-Init."
  qm set "$VM_ID" --boot c --bootdisk scsi0 || error_exit "Falha ao configurar o boot."
  qm set "$VM_ID" --serial0 socket --vga std || error_exit "Falha ao configurar VGA padrão."

  echo "Convertendo para template"
  qm template "$VM_ID" || error_exit "Falha ao converter para template."

  echo "Template $TEMPLATE_NAME criado com sucesso."
}

# Função VM COMUM
# Função para criar o template no Proxmox
create_template_comum() {
  echo "Criando template $TEMPLATE_NAME com ID $VM_ID..."

  echo "Remoção de uma possível VM com o mesmo ID"
  qm destroy "$VM_ID" --purge &> /dev/null || echo "Nenhuma VM com ID $VM_ID encontrada para remover."

  # Instalação do qemu-guest-agent, SSH, configuração do sshd_config e cópia das chaves SSH
  echo "Instalando qemu-guest-agent, SSH e copiando configuração sshd_config e chaves SSH na imagem..."
  virt-customize -a "$IMAGE_NAME" --install qemu-guest-agent,openssh-server || error_exit "Falha ao instalar qemu-guest-agent e SSH."
  virt-customize -a "$IMAGE_NAME" --copy-in "$SSHD_CONFIG_FILE":/etc/ssh || error_exit "Falha ao copiar sshd_config."

  echo "Criação do diretório ~/.ssh"
  virt-customize -a "$IMAGE_NAME" --run-command 'mkdir -p /root/.ssh && chmod 700 /root/.ssh' || error_exit "Falha ao criar diretório ~/.ssh."

  echo "Criação do diretório /home/notroot/.ssh/"
  virt-customize -a "$IMAGE_NAME" --run-command 'mkdir -p /home/notroot/.ssh/ && chmod 700 /home/notroot/.ssh/' || error_exit "Falha ao criar diretório /home/notroot/.ssh/"

  echo "Cópia das chaves pública e privada - /root/.ssh/"
  virt-customize -a "$IMAGE_NAME" --copy-in "$PUBLIC_KEY_FILE":/root/.ssh/ || error_exit "Falha ao copiar chave pública."
  virt-customize -a "$IMAGE_NAME" --copy-in "$PRIVATE_KEY_FILE":/root/.ssh/ || error_exit "Falha ao copiar chave privada."

    echo "Ajuste de permissões das chaves - /root/.ssh/"
    virt-customize -a "$IMAGE_NAME" --run-command 'chmod 600 /root/.ssh/id_rsa' || error_exit "Falha ao ajustar permissões das chaves SSH."
    virt-customize -a "$IMAGE_NAME" --run-command 'chmod 644 /root/.ssh/id_rsa.pub' || error_exit "Falha ao ajustar permissões das chaves SSH."

  echo "Cópia das chaves pública e privada - /home/notroot/.ssh/"
  virt-customize -a "$IMAGE_NAME" --copy-in "$PUBLIC_KEY_FILE":/home/notroot/.ssh/ || error_exit "Falha ao copiar chave pública."
  virt-customize -a "$IMAGE_NAME" --copy-in "$PRIVATE_KEY_FILE":/home/notroot/.ssh/ || error_exit "Falha ao copiar chave privada."

    echo "Ajuste de permissões das chaves - /home/notroot/.ssh/"
    virt-customize -a "$IMAGE_NAME" --run-command 'chmod 600 /home/notroot/.ssh/id_rsa' || error_exit "Falha ao ajustar permissões das chaves SSH."
    virt-customize -a "$IMAGE_NAME" --run-command 'chmod 644 /home/notroot/.ssh/id_rsa.pub' || error_exit "Falha ao ajustar permissões das chaves SSH."

  echo "Copiar o script para a imagem"
  virt-customize -a "$IMAGE_NAME" --copy-in "$SCRIPT_FILE":/usr/local/bin/ || error_exit "Falha ao copiar o script."

  echo "Tornar o script executável"
  virt-customize -a "$IMAGE_NAME" --run-command "chmod +x /usr/local/bin/$SCRIPT_FILE" || error_exit "Falha ao tornar o script executável."

  echo "Criar o arquivo de serviço systemd"
  virt-customize -a "$IMAGE_NAME" --run-command "echo -e '[Unit]\nDescription=Executar script customizado no boot\n\n[Service]\nType=simple\nExecStart=/usr/local/bin/$SCRIPT_FILE\n\n[Install]\nWantedBy=multi-user.target' > /etc/systemd/system/custom-script.service" || error_exit "Falha ao criar o arquivo de serviço systemd."

  echo "Habilitar o serviço para iniciar no boot"
  virt-customize -a "$IMAGE_NAME" --run-command 'systemctl enable custom-script.service' || error_exit "Falha ao habilitar o serviço no systemd."

  echo "Criação da VM no Proxmox"
  qm create "$VM_ID" --name "$TEMPLATE_NAME" --memory "$MEMORY" --cores "$CORES" --net0 virtio,bridge=vmbr0 || error_exit "Falha ao criar VM."
  qm importdisk "$VM_ID" "$IMAGE_NAME" "$VOLUME_NAME" || error_exit "Falha ao importar disco."
  qm set "$VM_ID" --scsihw virtio-scsi-single --scsi0 "$VOLUME_NAME:vm-$VM_ID-disk-0" || error_exit "Falha ao configurar o SCSI."
  qm set "$VM_ID" --agent enabled=1,fstrim_cloned_disks=1 || error_exit "Falha ao configurar o agente."

  echo "Configuração do Cloud-Init Disk, boot e vídeo padrão"
  qm set "$VM_ID" --ide2 "$VOLUME_NAME:cloudinit" || error_exit "Falha ao configurar Cloud-Init."
  qm set "$VM_ID" --boot c --bootdisk scsi0 || error_exit "Falha ao configurar o boot."
  qm set "$VM_ID" --serial0 socket --vga std || error_exit "Falha ao configurar VGA padrão."

  echo "Convertendo para template"
  qm template "$VM_ID" || error_exit "Falha ao converter para template."

  echo "Template $TEMPLATE_NAME criado com sucesso."
}

# DNS 1
# Função para criar o template no Proxmox
create_template_dns1() {
  echo "Criando template $TEMPLATE_NAME com ID $VM_ID..."

  echo "Remoção de uma possível VM com o mesmo ID"
  qm destroy "$VM_ID" --purge &> /dev/null || echo "Nenhuma VM com ID $VM_ID encontrada para remover."

  # Instalação do qemu-guest-agent, SSH, configuração do sshd_config e cópia das chaves SSH
  echo "Instalando qemu-guest-agent, SSH e copiando configuração sshd_config e chaves SSH na imagem..."
  virt-customize -a "$IMAGE_NAME" --install qemu-guest-agent,openssh-server,bind9,bind9utils,bind9-doc,sudo || error_exit "Falha ao instalar qemu-guest-agent, SSH e Bind."
  virt-customize -a "$IMAGE_NAME" --copy-in "$SSHD_CONFIG_FILE":/etc/ssh || error_exit "Falha ao copiar sshd_config."

  echo "Criação do diretório ~/.ssh"
  virt-customize -a "$IMAGE_NAME" --run-command 'mkdir -p /root/.ssh && chmod 700 /root/.ssh' || error_exit "Falha ao criar diretório ~/.ssh."

  echo "Criação do diretório /home/notroot/.ssh/"
  virt-customize -a "$IMAGE_NAME" --run-command 'mkdir -p /home/notroot/.ssh/ && chmod 700 /home/notroot/.ssh/' || error_exit "Falha ao criar diretório /home/notroot/.ssh/"

  echo "Cópia das chaves pública e privada - /root/.ssh/"
  virt-customize -a "$IMAGE_NAME" --copy-in "$PUBLIC_KEY_FILE":/root/.ssh/ || error_exit "Falha ao copiar chave pública."
  virt-customize -a "$IMAGE_NAME" --copy-in "$PRIVATE_KEY_FILE":/root/.ssh/ || error_exit "Falha ao copiar chave privada."

    echo "Ajuste de permissões das chaves - /root/.ssh/"
    virt-customize -a "$IMAGE_NAME" --run-command 'chmod 600 /root/.ssh/id_rsa' || error_exit "Falha ao ajustar permissões das chaves SSH."
    virt-customize -a "$IMAGE_NAME" --run-command 'chmod 644 /root/.ssh/id_rsa.pub' || error_exit "Falha ao ajustar permissões das chaves SSH."

  echo "Cópia das chaves pública e privada - /home/notroot/.ssh/"
  virt-customize -a "$IMAGE_NAME" --copy-in "$PUBLIC_KEY_FILE":/home/notroot/.ssh/ || error_exit "Falha ao copiar chave pública."
  virt-customize -a "$IMAGE_NAME" --copy-in "$PRIVATE_KEY_FILE":/home/notroot/.ssh/ || error_exit "Falha ao copiar chave privada."

    echo "Ajuste de permissões das chaves - /home/notroot/.ssh/"
    virt-customize -a "$IMAGE_NAME" --run-command 'chmod 600 /home/notroot/.ssh/id_rsa' || error_exit "Falha ao ajustar permissões das chaves SSH."
    virt-customize -a "$IMAGE_NAME" --run-command 'chmod 644 /home/notroot/.ssh/id_rsa.pub' || error_exit "Falha ao ajustar permissões das chaves SSH."

  echo "Copiar o script para a imagem"
  virt-customize -a "$IMAGE_NAME" --copy-in "$SCRIPT_FILE_dns":/usr/local/bin/ || error_exit "Falha ao copiar o script."
  echo "Tornar o script executável"
  virt-customize -a "$IMAGE_NAME" --run-command "chmod +x /usr/local/bin/$SCRIPT_FILE_dns" || error_exit "Falha ao tornar o script executável."
  echo "Criar o arquivo de serviço systemd"
  virt-customize -a "$IMAGE_NAME" --run-command "echo -e '[Unit]\nDescription=Executar script customizado no boot\n\n[Service]\nType=simple\nExecStart=/usr/local/bin/$SCRIPT_FILE_dns\n\n[Install]\nWantedBy=multi-user.target' > /etc/systemd/system/custom-script.service" || error_exit "Falha ao criar o arquivo de serviço systemd."
  echo "Habilitar o serviço para iniciar no boot"
  virt-customize -a "$IMAGE_NAME" --run-command 'systemctl enable custom-script.service' || error_exit "Falha ao habilitar o serviço no systemd."

  echo "Criando e copiando a pasta do sistema BIND para dentro da imagem"
  virt-customize -a "$IMAGE_NAME" --copy-in "${Dir_dnsns1}/.":/etc/bind

  echo "Criação da VM no Proxmox"
  qm create "$VM_ID" --name "$TEMPLATE_NAME" --memory "$MEMORY" --cores "$CORES" --net0 virtio,bridge=vmbr0 || error_exit "Falha ao criar VM."
  qm importdisk "$VM_ID" "$IMAGE_NAME" "$VOLUME_NAME" || error_exit "Falha ao importar disco."
  qm set "$VM_ID" --scsihw virtio-scsi-single --scsi0 "$VOLUME_NAME:vm-$VM_ID-disk-0" || error_exit "Falha ao configurar o SCSI."
  qm set "$VM_ID" --agent enabled=1,fstrim_cloned_disks=1 || error_exit "Falha ao configurar o agente."

  echo "Configuração do Cloud-Init Disk, boot e vídeo padrão"
  qm set "$VM_ID" --ide2 "$VOLUME_NAME:cloudinit" || error_exit "Falha ao configurar Cloud-Init."
  qm set "$VM_ID" --boot c --bootdisk scsi0 || error_exit "Falha ao configurar o boot."
  qm set "$VM_ID" --serial0 socket --vga std || error_exit "Falha ao configurar VGA padrão."

  echo "Convertendo para template"
  qm template "$VM_ID" || error_exit "Falha ao converter para template."

  echo "Template $TEMPLATE_NAME criado com sucesso."
}

# DNS 2
# Função para criar o template no Proxmox
create_template_dns2() {
  echo "Criando template $TEMPLATE_NAME com ID $VM_ID..."

  echo "Remoção de uma possível VM com o mesmo ID"
  qm destroy "$VM_ID" --purge &> /dev/null || echo "Nenhuma VM com ID $VM_ID encontrada para remover."

  # Instalação do qemu-guest-agent, SSH, configuração do sshd_config e cópia das chaves SSH
  echo "Instalando qemu-guest-agent, SSH e copiando configuração sshd_config e chaves SSH na imagem..."
  virt-customize -a "$IMAGE_NAME" --install qemu-guest-agent,openssh-server,bind9,bind9utils,bind9-doc,sudo || error_exit "Falha ao instalar qemu-guest-agent, SSH e Bind."
  virt-customize -a "$IMAGE_NAME" --copy-in "$SSHD_CONFIG_FILE":/etc/ssh || error_exit "Falha ao copiar sshd_config."

  echo "Criação do diretório ~/.ssh"
  virt-customize -a "$IMAGE_NAME" --run-command 'mkdir -p /root/.ssh && chmod 700 /root/.ssh' || error_exit "Falha ao criar diretório ~/.ssh."

  echo "Criação do diretório /home/notroot/.ssh/"
  virt-customize -a "$IMAGE_NAME" --run-command 'mkdir -p /home/notroot/.ssh/ && chmod 700 /home/notroot/.ssh/' || error_exit "Falha ao criar diretório /home/notroot/.ssh/"

  echo "Cópia das chaves pública e privada - /root/.ssh/"
  virt-customize -a "$IMAGE_NAME" --copy-in "$PUBLIC_KEY_FILE":/root/.ssh/ || error_exit "Falha ao copiar chave pública."
  virt-customize -a "$IMAGE_NAME" --copy-in "$PRIVATE_KEY_FILE":/root/.ssh/ || error_exit "Falha ao copiar chave privada."

    echo "Ajuste de permissões das chaves - /root/.ssh/"
    virt-customize -a "$IMAGE_NAME" --run-command 'chmod 600 /root/.ssh/id_rsa' || error_exit "Falha ao ajustar permissões das chaves SSH."
    virt-customize -a "$IMAGE_NAME" --run-command 'chmod 644 /root/.ssh/id_rsa.pub' || error_exit "Falha ao ajustar permissões das chaves SSH."

  echo "Cópia das chaves pública e privada - /home/notroot/.ssh/"
  virt-customize -a "$IMAGE_NAME" --copy-in "$PUBLIC_KEY_FILE":/home/notroot/.ssh/ || error_exit "Falha ao copiar chave pública."
  virt-customize -a "$IMAGE_NAME" --copy-in "$PRIVATE_KEY_FILE":/home/notroot/.ssh/ || error_exit "Falha ao copiar chave privada."

    echo "Ajuste de permissões das chaves - /home/notroot/.ssh/"
    virt-customize -a "$IMAGE_NAME" --run-command 'chmod 600 /home/notroot/.ssh/id_rsa' || error_exit "Falha ao ajustar permissões das chaves SSH."
    virt-customize -a "$IMAGE_NAME" --run-command 'chmod 644 /home/notroot/.ssh/id_rsa.pub' || error_exit "Falha ao ajustar permissões das chaves SSH."

  echo "Copiar o script para a imagem"
  virt-customize -a "$IMAGE_NAME" --copy-in "$SCRIPT_FILE_dns":/usr/local/bin/ || error_exit "Falha ao copiar o script."
  echo "Tornar o script executável"
  virt-customize -a "$IMAGE_NAME" --run-command "chmod +x /usr/local/bin/$SCRIPT_FILE_dns" || error_exit "Falha ao tornar o script executável."
  echo "Criar o arquivo de serviço systemd"
  virt-customize -a "$IMAGE_NAME" --run-command "echo -e '[Unit]\nDescription=Executar script customizado no boot\n\n[Service]\nType=simple\nExecStart=/usr/local/bin/$SCRIPT_FILE_dns\n\n[Install]\nWantedBy=multi-user.target' > /etc/systemd/system/custom-script.service" || error_exit "Falha ao criar o arquivo de serviço systemd."
  echo "Habilitar o serviço para iniciar no boot"
  virt-customize -a "$IMAGE_NAME" --run-command 'systemctl enable custom-script.service' || error_exit "Falha ao habilitar o serviço no systemd."

  echo "Criando e copiando a pasta do sistema BIND para dentro da imagem"
  virt-customize -a "$IMAGE_NAME" --copy-in "${Dir_dnsns2}/.":/etc/bind

  echo "Criação da VM no Proxmox"
  qm create "$VM_ID" --name "$TEMPLATE_NAME" --memory "$MEMORY" --cores "$CORES" --net0 virtio,bridge=vmbr0 || error_exit "Falha ao criar VM."
  qm importdisk "$VM_ID" "$IMAGE_NAME" "$VOLUME_NAME" || error_exit "Falha ao importar disco."
  qm set "$VM_ID" --scsihw virtio-scsi-single --scsi0 "$VOLUME_NAME:vm-$VM_ID-disk-0" || error_exit "Falha ao configurar o SCSI."
  qm set "$VM_ID" --agent enabled=1,fstrim_cloned_disks=1 || error_exit "Falha ao configurar o agente."

  echo "Configuração do Cloud-Init Disk, boot e vídeo padrão"
  qm set "$VM_ID" --ide2 "$VOLUME_NAME:cloudinit" || error_exit "Falha ao configurar Cloud-Init."
  qm set "$VM_ID" --boot c --bootdisk scsi0 || error_exit "Falha ao configurar o boot."
  qm set "$VM_ID" --serial0 socket --vga std || error_exit "Falha ao configurar VGA padrão."

  echo "Convertendo para template"
  qm template "$VM_ID" || error_exit "Falha ao converter para template."

  echo "Template $TEMPLATE_NAME criado com sucesso."
}

# Função VM  NFS
# Função para criar o template no Proxmox
create_template_nfs() {
  echo "Criando template $TEMPLATE_NAME com ID $VM_ID..."

  echo "Remoção de uma possível VM com o mesmo ID"
  qm destroy "$VM_ID" --purge &> /dev/null || echo "Nenhuma VM com ID $VM_ID encontrada para remover."

  # Instalação do qemu-guest-agent, SSH, configuração do sshd_config e cópia das chaves SSH
  echo "Instalando qemu-guest-agent, SSH e copiando configuração sshd_config e chaves SSH na imagem..."
  virt-customize -a "$IMAGE_NAME" --install qemu-guest-agent,openssh-server || error_exit "Falha ao instalar qemu-guest-agent e SSH."
  virt-customize -a "$IMAGE_NAME" --copy-in "$SSHD_CONFIG_FILE":/etc/ssh || error_exit "Falha ao copiar sshd_config."

  echo "Criação do diretório ~/.ssh"
  virt-customize -a "$IMAGE_NAME" --run-command 'mkdir -p /root/.ssh && chmod 700 /root/.ssh' || error_exit "Falha ao criar diretório ~/.ssh."

  echo "Criação do diretório /home/notroot/.ssh/"
  virt-customize -a "$IMAGE_NAME" --run-command 'mkdir -p /home/notroot/.ssh/ && chmod 700 /home/notroot/.ssh/' || error_exit "Falha ao criar diretório /home/notroot/.ssh/"

  echo "Cópia das chaves pública e privada - /root/.ssh/"
  virt-customize -a "$IMAGE_NAME" --copy-in "$PUBLIC_KEY_FILE":/root/.ssh/ || error_exit "Falha ao copiar chave pública."
  virt-customize -a "$IMAGE_NAME" --copy-in "$PRIVATE_KEY_FILE":/root/.ssh/ || error_exit "Falha ao copiar chave privada."

  echo "Ajuste de permissões das chaves - /root/.ssh/"
  virt-customize -a "$IMAGE_NAME" --run-command 'chmod 600 /root/.ssh/id_rsa' || error_exit "Falha ao ajustar permissões das chaves SSH."
  virt-customize -a "$IMAGE_NAME" --run-command 'chmod 644 /root/.ssh/id_rsa.pub' || error_exit "Falha ao ajustar permissões das chaves SSH."

  echo "Cópia das chaves pública e privada - /home/notroot/.ssh/"
  virt-customize -a "$IMAGE_NAME" --copy-in "$PUBLIC_KEY_FILE":/home/notroot/.ssh/ || error_exit "Falha ao copiar chave pública."
  virt-customize -a "$IMAGE_NAME" --copy-in "$PRIVATE_KEY_FILE":/home/notroot/.ssh/ || error_exit "Falha ao copiar chave privada."

  echo "Ajuste de permissões das chaves - /home/notroot/.ssh/"
  virt-customize -a "$IMAGE_NAME" --run-command 'chmod 600 /home/notroot/.ssh/id_rsa' || error_exit "Falha ao ajustar permissões das chaves SSH."
  virt-customize -a "$IMAGE_NAME" --run-command 'chmod 644 /home/notroot/.ssh/id_rsa.pub' || error_exit "Falha ao ajustar permissões das chaves SSH."

  echo "Copiar o script para a imagem"
  virt-customize -a "$IMAGE_NAME" --copy-in "$SCRIPT_FILE_nfs":/usr/local/bin/ || error_exit "Falha ao copiar o script."

  echo "Tornar o script executável"
  virt-customize -a "$IMAGE_NAME" --run-command "chmod +x /usr/local/bin/$SCRIPT_FILE_nfs" || error_exit "Falha ao tornar o script executável."

  echo "Criar o arquivo de serviço systemd"
  virt-customize -a "$IMAGE_NAME" --run-command "echo -e '[Unit]\nDescription=Executar script customizado no boot\n\n[Service]\nType=simple\nExecStart=/usr/local/bin/$SCRIPT_FILE_nfs\n\n[Install]\nWantedBy=multi-user.target' > /etc/systemd/system/custom-script.service" || error_exit "Falha ao criar o arquivo de serviço systemd."

  echo "Habilitar o serviço para iniciar no boot"
  virt-customize -a "$IMAGE_NAME" --run-command 'systemctl enable custom-script.service' || error_exit "Falha ao habilitar o serviço no systemd."

  # Instalação e configuração do servidor NFS
  echo "Instalando e configurando servidor NFS na imagem..."
  virt-customize -a "$IMAGE_NAME" --install nfs-kernel-server || error_exit "Falha ao instalar o servidor NFS."

  echo "Criando diretórios para compartilhamento NFS..."
  virt-customize -a "$IMAGE_NAME" --run-command 'mkdir -p /srv/nfs/torrent /srv/nfs/music && chown nobody:nogroup /srv/nfs/torrent /srv/nfs/music && chmod 777 /srv/nfs/torrent /srv/nfs/music && echo "/srv/nfs/torrent 192.168.3.10(rw,sync,no_subtree_check,all_squash,anonuid=65534,anongid=65534)" >> /etc/exports && echo "/srv/nfs/torrent 192.168.3.11(rw,sync,no_subtree_check,all_squash,anonuid=65534,anongid=65534)" >> /etc/exports && echo "/srv/nfs/torrent 192.168.3.12(rw,sync,no_subtree_check,all_squash,anonuid=65534,anongid=65534)" >> /etc/exports && echo "/srv/nfs/torrent 192.168.3.13(rw,sync,no_subtree_check,all_squash,anonuid=65534,anongid=65534)" >> /etc/exports && echo "/srv/nfs/music 192.168.3.10(rw,sync,no_subtree_check,all_squash,anonuid=65534,anongid=65534)" >> /etc/exports && echo "/srv/nfs/music 192.168.3.11(rw,sync,no_subtree_check,all_squash,anonuid=65534,anongid=65534)" >> /etc/exports && echo "/srv/nfs/music 192.168.3.12(rw,sync,no_subtree_check,all_squash,anonuid=65534,anongid=65534)" >> /etc/exports && echo "/srv/nfs/music 192.168.3.13(rw,sync,no_subtree_check,all_squash,anonuid=65534,anongid=65534)" >> /etc/exports' || error_exit "Falha ao criar diretórios NFS e configurar permissões."

  echo "Configurando /etc/exports para exportação NFS..."
  virt-customize -a "$IMAGE_NAME" --run-command "echo -e '/srv/nfs/torrent *(rw,sync,no_subtree_check)\n/srv/nfs/music *(rw,sync,no_subtree_check)' >> /etc/exports" || error_exit "Falha ao configurar /etc/exports."

  echo "Criação da VM no Proxmox"
  qm create "$VM_ID" --name "$TEMPLATE_NAME" --memory "$MEMORY" --cores "$CORES" --net0 virtio,bridge=vmbr0 || error_exit "Falha ao criar VM."
  qm importdisk "$VM_ID" "$IMAGE_NAME" "$VOLUME_NAME" || error_exit "Falha ao importar disco."
  qm set "$VM_ID" --scsihw virtio-scsi-single --scsi0 "$VOLUME_NAME:vm-$VM_ID-disk-0" || error_exit "Falha ao configurar o SCSI."
  qm set "$VM_ID" --agent enabled=1,fstrim_cloned_disks=1 || error_exit "Falha ao configurar o agente."

  echo "Configuração do Cloud-Init Disk, boot e vídeo padrão"
  qm set "$VM_ID" --ide2 "$VOLUME_NAME:cloudinit" || error_exit "Falha ao configurar Cloud-Init."
  qm set "$VM_ID" --boot c --bootdisk scsi0 || error_exit "Falha ao configurar o boot."
  qm set "$VM_ID" --serial0 socket --vga std || error_exit "Falha ao configurar VGA padrão."

  echo "Convertendo para template"
  qm template "$VM_ID" || error_exit "Falha ao converter para template."

  echo "Template $TEMPLATE_NAME criado com sucesso."
}

# Função principal
main() {
  install_dependencies
while true; do
    echo "\nMenu de Opções:"
    echo "1 - Criar imagem do Rancher"
    echo "2 - Criar imagem do Agente"
    echo "3 - Criar imagem do Comum"
    echo "4 - Criar imagem do DNS Master"
    echo "5 - Criar imagem do DNS Slave"
    echo "6 - Criar imagem do Servidor NFS"
    echo "7. Sair"

    read -p "Escolha uma opção: " opcao

    case $opcao in
        1)
            configure_image_params "$opcao"
            create_template_rancher
            ;;
        2)
            configure_image_params "$opcao"
            create_template_agentes
            ;;
        3)
            configure_image_params "$opcao"
            create_template_comum
            ;;
        4)
            configure_image_params "$opcao"
            create_template_dns1
            ;;
        5)
            configure_image_params "$opcao"
            create_template_dns2
            ;;
        6)
            configure_image_params "$opcao"
            create_template_nfs
            ;;
        7)
            echo "Saindo..."
            exit 0
            ;;
        *)
            echo "Opção inválida. Por favor, escolha uma opção válida."
            ;;
    esac
done
}

# Execução do script
main