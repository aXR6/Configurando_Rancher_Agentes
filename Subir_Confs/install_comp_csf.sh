#!/bin/bash

# Verifica se o sendmail já está instalado
if ! command -v sendmail &> /dev/null
then
    echo "sendmail não está instalado. Instalando..."
    sudo apt update && sudo apt-get install sendmail -y
fi

# Verifica se o dnsutils já está instalado
if ! command -v nslookup &> /dev/null
then
    echo "dnsutils não está instalado. Instalando..."
    sudo apt update && sudo apt-get install dnsutils -y
fi

# Verifica se o unzip já está instalado
if ! command -v unzip &> /dev/null
then
    echo "unzip não está instalado. Instalando..."
    sudo apt update && sudo apt-get install unzip -y
fi

# Verifica se o csf já está instalado
if ! command -v csf &> /dev/null
then
    echo "CSF não está instalado. Instalando..."
    sudo apt update && sudo apt-get install libio-socket-ssl-perl libcrypt-ssleay-perl git perl iptables libnet-libidn-perl libio-socket-inet6-perl libsocket6-perl -y
    cd /usr/src/csf/
    sudo ./install.sh
    sudo systemctl enable csf
    sudo systemctl start csf
    sudo apt autoremove -y
    sudo apt autoclean
fi

# Adiciona os IPs permitidos ao CSF
sudo csf -a 192.168.2.10 Rancher
sudo csf -a 192.168.2.11 "Primeiro agente do Rancher"
sudo csf -a 192.168.2.12 "Segundo agente do Rancher"
sudo csf -a 192.168.2.13 "Terceiro agente do Rancher"
sudo csf -a 192.168.2.50 "Servidor do ProxMox"
sudo csf -a 192.168.2.51 "Servidor do ProxMox"
sudo csf -a 192.168.2.200 "Servidor de DNS - NS1"
sudo csf -a 192.168.2.201 "Servidor de DNS - NS2"
sudo csf -a 192.168.2.203 "Servidor de Torrent"
sudo csf -a 192.168.2.150 "Máquina terminal para comendos"
