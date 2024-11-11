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

# Lista pacotes que podem ser atualizados
echo "Listando pacotes que podem ser atualizados..."
apt list --upgradable

# Instala pacotes quebrados
echo "Corrigindo pacotes quebrados..."
sudo apt --fix-broken install -y || { echo "Erro ao corrigir pacotes quebrados."; exit 1; }

# Realiza atualização completa do sistema
echo "Realizando dist-upgrade..."
sudo apt dist-upgrade -y || { echo "Erro ao realizar dist-upgrade."; exit 1; }

# Realiza atualizações gerais do sistema
echo "Atualizando todos os pacotes do sistema..."
sudo apt-get upgrade -y || { echo "Erro ao atualizar pacotes do sistema."; exit 1; }

# Remove pacotes obsoletos
echo "Removendo pacotes obsoletos..."
sudo apt-get autoremove -y || { echo "Erro ao remover pacotes obsoletos."; exit 1; }

# Executa limpeza de pacotes
echo "Executando limpeza de pacotes..."
sudo apt-get autoclean || { echo "Erro ao realizar autoclean."; exit 1; }

# Limpa cache de pacotes
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

# Adicionar o usuário 'root' ao grupo 'wheel'
USER_TO_ADD="root"
echo "Adicionando o usuário $USER_TO_ADD ao grupo 'wheel'..."
sudo usermod -aG wheel "$USER_TO_ADD" || { echo "Erro ao adicionar o usuário $USER_TO_ADD ao grupo 'wheel'."; exit 1; }

# Configurar DNS no /etc/resolv.conf
echo "Configurando DNS no /etc/resolv.conf..."
echo -e "search pve.datacenter.tsc\nnameserver 192.168.3.200\nnameserver 192.168.3.201\nnameserver 192.168.3.1\nnameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null || { echo "Erro ao configurar o /etc/resolv.conf."; exit 1; }

# Adiciona repositório do Kubernetes e instala o kubectl
echo "Configurando repositório do Kubernetes..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg || { echo "Erro ao baixar a chave do Kubernetes."; exit 1; }

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null || { echo "Erro ao adicionar o repositório do Kubernetes."; exit 1; }

sudo apt-get update || { echo "Erro ao atualizar repositórios após adicionar o Kubernetes."; exit 1; }
sudo apt-get install -y kubectl || { echo "Erro ao instalar o kubectl."; exit 1; }

echo "Processo concluído com sucesso."