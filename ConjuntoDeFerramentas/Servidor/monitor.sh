#!/bin/bash

# Função para verificar se os programas necessários estão instalados
verificar_dependencias() {
    echo "Verificando dependências..."
    for cmd in htop iotop iftop; do
        if ! command -v $cmd &> /dev/null; then
            echo "O programa $cmd não está instalado. Instalando..."
            sudo apt update && sudo apt install -y $cmd
        fi
    done
}

# Função para ajustar parâmetros de rede no sysctl
otimizar_rede() {
    echo "Otimizando parâmetros de rede..."
    sudo tee -a /etc/sysctl.conf > /dev/null <<EOL
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 4096
net.core.somaxconn = 1024
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_mtu_probing = 1
EOL
    sudo sysctl -p
    echo "Parâmetros de rede aplicados com sucesso."
}

# Função para aumentar limites de arquivos abertos
aumentar_limites() {
    echo "Aumentando limites de arquivos abertos..."
    sudo tee -a /etc/security/limits.conf > /dev/null <<EOL
*    soft    nofile  65535
*    hard    nofile  65535
EOL
    sudo tee -a /etc/systemd/system.conf > /dev/null <<EOL
DefaultLimitNOFILE=65535
EOL
    sudo tee -a /etc/systemd/user.conf > /dev/null <<EOL
DefaultLimitNOFILE=65535
EOL
    echo "Limites ajustados. Reinicie o sistema para aplicar totalmente as alterações."
}

# Função para configurar logs rotativos
configurar_logs() {
    echo "Configurando logs rotativos para o Transmission..."
    sudo tee /etc/logrotate.d/transmission > /dev/null <<EOL
/var/log/transmission/*.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    create 0640 debian-transmission debian-transmission
}
EOL
    sudo logrotate -f /etc/logrotate.conf
    echo "Configuração de logs rotativos aplicada."
}

# Função para configurar firewall para o Transmission
configurar_firewall() {
    echo "Configurando firewall para permitir portas do Transmission..."
    sudo apt install -y ufw
    sudo ufw allow 51413
    sudo ufw allow 9091
    sudo ufw enable
    echo "Firewall configurado com sucesso."
}

# Função para monitorar processos com htop
monitorar_processos() {
    echo "Abrindo o htop para monitorar processos..."
    htop
}

# Função para monitorar operações de IO com iotop
monitorar_io() {
    echo "Abrindo o iotop para monitorar operações de IO..."
    sudo iotop
}

# Função para monitorar tráfego de rede com iftop
monitorar_rede() {
    echo "Abrindo o iftop para monitorar tráfego de rede..."
    sudo iftop
}

# Menu principal
menu_principal() {
    while true; do
        echo "======================================"
        echo " Debian Torrent Optimizer - Menu "
        echo "======================================"
        echo "1. Monitorar Processos (htop)"
        echo "2. Monitorar Operações de IO (iotop)"
        echo "3. Monitorar Tráfego de Rede (iftop)"
        echo "4. Otimizar Rede (sysctl)"
        echo "5. Aumentar Limites de Arquivos Abertos"
        echo "6. Configurar Logs Rotativos"
        echo "7. Configurar Firewall para o Transmission"
        echo "8. Sair"
        echo "======================================"
        read -rp "Escolha uma opção: " opcao

        case $opcao in
            1) monitorar_processos ;;
            2) monitorar_io ;;
            3) monitorar_rede ;;
            4) otimizar_rede ;;
            5) aumentar_limites ;;
            6) configurar_logs ;;
            7) configurar_firewall ;;
            8) echo "Saindo..."; exit 0 ;;
            *) echo "Opção inválida! Tente novamente." ;;
        esac
    done
}

# Verificar dependências antes de executar o menu
verificar_dependencias

# Executar o menu principal
menu_principal