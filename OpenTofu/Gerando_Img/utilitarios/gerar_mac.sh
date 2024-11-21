#!/bin/bash

# Prefixo típico para endereços MAC de máquinas virtuais KVM/QEMU
PREFIX="52:54:00"

# Função para gerar octetos aleatórios usando /dev/urandom
generate_octet() {
    printf '%02X' $(od -An -N1 -i /dev/urandom)
}

# Gerando os últimos três octetos
OCT1=$(generate_octet)
OCT2=$(generate_octet)
OCT3=$(generate_octet)

# Combinando o prefixo com os octetos gerados
MAC_ADDRESS="$PREFIX:$OCT1:$OCT2:$OCT3"

# Registro de endereços MAC gerados (pode ser adaptado para persistência em um arquivo ou banco de dados)
LOG_FILE="/tmp/mac_addresses.log"

# Verificação de duplicidade
if [ -f "$LOG_FILE" ]; then
    while grep -q "$MAC_ADDRESS" "$LOG_FILE"; do
        OCT1=$(generate_octet)
        OCT2=$(generate_octet)
        OCT3=$(generate_octet)
        MAC_ADDRESS="$PREFIX:$OCT1:$OCT2:$OCT3"
    done
fi

# Registrando o endereço MAC no log
echo "$MAC_ADDRESS" >> "$LOG_FILE"

# Exibindo o endereço MAC gerado
echo "Endereço MAC gerado: $MAC_ADDRESS"