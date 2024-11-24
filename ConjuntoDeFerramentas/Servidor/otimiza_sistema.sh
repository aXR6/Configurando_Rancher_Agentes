#!/bin/bash

# Função para exibir o menu principal
menu_principal() {
    clear
    echo "============================================"
    echo "       Otimização de Sistema - Debian 12"
    echo "============================================"
    echo "1. Configurar Governador de CPU"
    echo "2. Ajustar Swappiness"
    echo "3. Habilitar TRIM para SSD"
    echo "4. Gerenciar Serviços em Inicialização"
    echo "5. Instalar Ferramentas de Otimização (TLP, Preload)"
    echo "6. Verificar Governadores Disponíveis"
    echo "7. Sair"
    echo "============================================"
    echo -n "Escolha uma opção: "
}

# Função para configurar o governador da CPU
configurar_governador() {
    echo "Governadores disponíveis:"
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
    echo -n "Digite o governador desejado (ex: performance): "
    read governador

    echo "Aplicando o governador $governador a todos os núcleos..."
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo $governador | sudo tee $cpu
    done
    echo "Governador configurado com sucesso!"
    sleep 2
}

# Função para ajustar o Swappiness
ajustar_swappiness() {
    echo -n "Digite o valor de swappiness desejado (recomendado: 10): "
    read valor
    echo "Configurando vm.swappiness=$valor..."
    echo "vm.swappiness=$valor" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
    echo "Swappiness ajustado para $valor!"
    sleep 2
}

# Função para habilitar TRIM para SSD
habilitar_trim() {
    echo "Habilitando TRIM para SSD..."
    sudo systemctl enable fstrim.timer
    sudo systemctl start fstrim.timer
    echo "TRIM habilitado e agendado!"
    sleep 2
}

# Função para gerenciar serviços na inicialização
gerenciar_servicos() {
    echo "Serviços habilitados na inicialização:"
    systemctl list-unit-files --state=enabled
    echo -n "Digite o nome do serviço a ser desativado (ou pressione Enter para voltar): "
    read servico

    if [ -n "$servico" ]; then
        sudo systemctl disable $servico
        echo "Serviço $servico desativado!"
    else
        echo "Nenhum serviço foi alterado."
    fi
    sleep 2
}

# Função para instalar ferramentas de otimização
instalar_ferramentas() {
    echo "Instalando TLP e Preload..."
    sudo apt update
    sudo apt install -y tlp preload
    sudo systemctl enable tlp
    echo "Ferramentas instaladas e configuradas!"
    sleep 2
}

# Função para verificar os governadores disponíveis
verificar_governadores() {
    echo "Governadores disponíveis:"
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
    sleep 2
}

# Loop principal
while true; do
    menu_principal
    read opcao

    case $opcao in
        1) configurar_governador ;;
        2) ajustar_swappiness ;;
        3) habilitar_trim ;;
        4) gerenciar_servicos ;;
        5) instalar_ferramentas ;;
        6) verificar_governadores ;;
        7) echo "Saindo..."; exit 0 ;;
        *) echo "Opção inválida!"; sleep 2 ;;
    esac
done