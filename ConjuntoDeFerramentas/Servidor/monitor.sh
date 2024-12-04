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
        echo "4. Configurar Logs Rotativos"
        echo "5. Sair"
        echo "======================================"
        read -rp "Escolha uma opção: " opcao

        case $opcao in
            1) monitorar_processos ;;
            2) monitorar_io ;;
            3) monitorar_rede ;;
            4) configurar_logs ;;
            5) echo "Saindo..."; exit 0 ;;
            *) echo "Opção inválida! Tente novamente." ;;
        esac
    done
}

# Verificar dependências antes de executar o menu
verificar_dependencias

# Executar o menu principal
menu_principal