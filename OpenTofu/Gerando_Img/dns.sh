#!/bin/bash

# Lista de pacotes necessários
PACKAGES=(bind9 bind9utils bind9-doc sudo)

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

# Verifica e cria o grupo 'wheel' se não existir
echo "Verificando a existência do grupo 'wheel'..."
if ! getent group wheel > /dev/null; then
  echo "Grupo 'wheel' não encontrado. Criando grupo 'wheel'..."
  sudo groupadd wheel || { echo "Erro ao criar o grupo 'wheel'."; exit 1; }
else
  echo "Grupo 'wheel' já existe."
fi

# Permitir que o grupo 'wheel' tenha sudo sem senha
echo "Configurando sudo sem senha para o grupo 'wheel'..."
echo "%wheel ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/wheel-nopasswd > /dev/null || { echo "Erro ao configurar sudo sem senha para o grupo 'wheel'."; exit 1; }

# Adicionar o usuário 'notroot' ao grupo 'wheel'
USER_TO_ADD="notroot"
echo "Adicionando o usuário $USER_TO_ADD ao grupo 'wheel'..."
sudo usermod -aG wheel "$USER_TO_ADD" || { echo "Erro ao adicionar o usuário $USER_TO_ADD ao grupo 'wheel'."; exit 1; }

echo "Processo concluído com sucesso."