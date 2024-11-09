#!/bin/bash

# Gerando o prefixo para MAC de forma que comece com 52:54:00 (prefixo típico para KVM/QEMU)
PREFIX="52:54:00"

# Gerando os últimos três octetos de forma aleatória
OCT1=$(printf '%02X' $((RANDOM % 256)))
OCT2=$(printf '%02X' $((RANDOM % 256)))
OCT3=$(printf '%02X' $((RANDOM % 256)))

# Combinando o prefixo com os octetos gerados
MAC_ADDRESS="$PREFIX:$OCT1:$OCT2:$OCT3"

echo "Endereço MAC gerado: $MAC_ADDRESS"