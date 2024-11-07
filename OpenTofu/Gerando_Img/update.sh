#!/bin/bash

# Lista de pacotes necessários
PACKAGES=(bash curl grep mawk open-iscsi util-linux wget sudo)

# Função para verificar se um pacote está instalado
is_installed() {
  dpkg -s "$1" &> /dev/null
}

# Atualiza os repositórios
echo "Atualizando repositórios..."
sudo apt update || { echo "Erro ao atualizar repositórios."; exit 1; }

# Verifica e instala pacotes necessários
for package in "${PACKAGES[@]}"; do
  if is_installed "$package"; then
    echo "O pacote $package já está instalado. Verificando por atualizações..."
    sudo apt install --only-upgrade -y "$package" || echo "Falha ao atualizar $package."
  else
    echo "O pacote $package não está instalado. Instalando..."
    sudo apt install -y "$package" || { echo "Erro ao instalar $package."; exit 1; }
  fi
done

# Realiza atualizações gerais do sistema
echo "Atualizando todos os pacotes do sistema..."
sudo apt-get upgrade -y || { echo "Erro ao atualizar pacotes do sistema."; exit 1; }

echo "Removendo pacotes obsoletos..."
sudo apt-get autoremove -y || { echo "Erro ao remover pacotes obsoletos."; exit 1; }

echo "Executando limpeza de pacotes..."
sudo apt-get autoclean || { echo "Erro ao realizar autoclean."; exit 1; }

echo "Limpando cache de pacotes..."
sudo apt-get clean || { echo "Erro ao limpar cache de pacotes."; exit 1; }

echo "Processo concluído com sucesso."