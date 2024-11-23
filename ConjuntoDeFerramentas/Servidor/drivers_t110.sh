#!/bin/bash

# Verifica se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, execute como root."
  exit 1
fi

echo "Atualizando o sistema e instalando os pacotes necessários..."
apt update && apt upgrade -y

# Função para verificar e instalar pacotes necessários
install_package() {
  PACKAGE=$1
  if ! dpkg -l | grep -q "$PACKAGE"; then
    echo "Instalando $PACKAGE..."
    apt install -y "$PACKAGE"
  else
    echo "$PACKAGE já está instalado."
  fi
}

# Drivers para o chipset Intel
echo "Instalando drivers para o chipset Intel..."
install_package "firmware-misc-nonfree"
install_package "firmware-linux-nonfree"

# Codec de vídeo
echo "Instalando CODEC de vídeo"
install_package "ffmpeg intel-media-va-driver i965-va-driver"

# Drivers para Ethernet Broadcom NetXtreme BCM5722
echo "Instalando drivers para Ethernet Broadcom NetXtreme BCM5722..."
install_package "firmware-bnx2"
install_package "firmware-brcm80211"
install_package "broadcom-sta-dkms"

# Drivers para o controlador de vídeo Matrox MGA G200eW
echo "Instalando drivers para o controlador de vídeo Matrox..."
install_package "xserver-xorg-video-mga"

# Configuração de dispositivos PCI relacionados ao controlador SATA
echo "Instalando suporte para o controlador SATA AHCI..."
modprobe ahci

# Configuração de USB e SMBus
echo "Instalando drivers para USB e SMBus..."
install_package "usbutils"
install_package "i2c-tools"

# Reconfigurando módulos e reiniciando os serviços
echo "Recarregando os módulos do kernel..."
depmod -a
update-initramfs -u

echo "Drivers instalados com sucesso. Recomenda-se reiniciar o sistema para aplicar as alterações."