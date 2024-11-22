#!/bin/bash

# Configurações
IP_SERVER="192.168.3.202"
IP_CLIENT="192.168.3.20"
TRANSMISSION_DOWNLOADS="/home/stream/transmission/downloads"
MUSICAS="/home/stream/musicas"
NFS_EXPORTS_FILE="/etc/exports"
MOUNT_TRANSMISSION="/mnt/transmission_downloads"
MOUNT_MUSICAS="/mnt/musicas"

# Função para configurar o servidor NFS
configurar_servidor() {
    echo "Configurando o servidor NFS..."

    # Instalar NFS server (se necessário)
    echo "Instalando servidor NFS..."
    sudo apt update && sudo apt install -y nfs-kernel-server

    # Configurar a pasta de downloads do Transmission
    echo "Configurando o compartilhamento da pasta de downloads do Transmission..."
    if [ ! -d "$TRANSMISSION_DOWNLOADS" ]; then
        echo "Criando o diretório $TRANSMISSION_DOWNLOADS..."
        sudo mkdir -p "$TRANSMISSION_DOWNLOADS"
    fi
    sudo chmod -R 777 "$TRANSMISSION_DOWNLOADS"
    sudo chown -R nobody:nogroup "$TRANSMISSION_DOWNLOADS"
    if ! grep -q "$TRANSMISSION_DOWNLOADS $IP_CLIENT" "$NFS_EXPORTS_FILE"; then
        echo "$TRANSMISSION_DOWNLOADS $IP_CLIENT(rw,sync,no_subtree_check)" | sudo tee -a "$NFS_EXPORTS_FILE"
    fi

    # Configurar a pasta de músicas
    echo "Configurando o compartilhamento da pasta de músicas..."
    if [ ! -d "$MUSICAS" ]; then
        echo "Criando o diretório $MUSICAS..."
        sudo mkdir -p "$MUSICAS"
    fi
    sudo chmod -R 777 "$MUSICAS"
    sudo chown -R nobody:nogroup "$MUSICAS"
    if ! grep -q "$MUSICAS $IP_CLIENT" "$NFS_EXPORTS_FILE"; then
        echo "$MUSICAS $IP_CLIENT(rw,sync,no_subtree_check)" | sudo tee -a "$NFS_EXPORTS_FILE"
    fi

    # Reiniciar o serviço NFS
    echo "Reiniciando o serviço NFS..."
    sudo systemctl restart nfs-kernel-server

    echo "Configuração do servidor concluída! As pastas foram compartilhadas para o cliente $IP_CLIENT."
}

# Função para configurar o cliente NFS
configurar_cliente() {
    echo "Configurando o cliente NFS para acessar as pastas compartilhadas no servidor $IP_SERVER..."

    # Instalar NFS client (se necessário)
    echo "Instalando cliente NFS..."
    sudo apt update && sudo apt install -y nfs-common

    # Configurar ponto de montagem para downloads do Transmission
    echo "Criando ponto de montagem em $MOUNT_TRANSMISSION..."
    sudo mkdir -p "$MOUNT_TRANSMISSION"
    if ! grep -q "$IP_SERVER:$TRANSMISSION_DOWNLOADS" /etc/fstab; then
        echo "$IP_SERVER:$TRANSMISSION_DOWNLOADS $MOUNT_TRANSMISSION nfs defaults 0 0" | sudo tee -a /etc/fstab
    fi

    # Configurar ponto de montagem para músicas
    echo "Criando ponto de montagem em $MOUNT_MUSICAS..."
    sudo mkdir -p "$MOUNT_MUSICAS"
    if ! grep -q "$IP_SERVER:$MUSICAS" /etc/fstab; then
        echo "$IP_SERVER:$MUSICAS $MOUNT_MUSICAS nfs defaults 0 0" | sudo tee -a /etc/fstab
    fi

    # Montar os compartilhamentos
    echo "Montando os compartilhamentos NFS..."
    sudo mount -a

    echo "Configuração do cliente concluída! As pastas foram montadas em $MOUNT_TRANSMISSION e $MOUNT_MUSICAS com permissões de leitura e escrita."
}

# Função principal do menu
menu_principal() {
    while true; do
        echo "Selecione a opção desejada:"
        echo "1. Configurar servidor NFS (compartilhar pastas)"
        echo "2. Configurar cliente NFS (acessar pastas compartilhadas)"
        echo "3. Sair"
        read -rp "Opção: " opcao

        case $opcao in
            1) configurar_servidor ;;
            2) configurar_cliente ;;
            3) echo "Saindo..."; exit 0 ;;
            *) echo "Opção inválida! Tente novamente." ;;
        esac
    done
}

# Executar o menu principal
menu_principal