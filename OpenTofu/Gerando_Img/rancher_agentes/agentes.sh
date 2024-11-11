#!/bin/bash

# Lista de pacotes necessários
PACKAGES=(bash grep mawk open-iscsi util-linux wget nfs-common)

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

# Configuração do cliente NFS (executa apenas uma vez)
NFS_SERVER_IP="192.168.1.100"  # Substitua pelo IP do servidor NFS
NFS_TORRENT_DIR="/mnt/nfs/torrent"
NFS_MUSIC_DIR="/mnt/nfs/music"

# Verificação se o NFS já está configurado
if ! mountpoint -q "$NFS_TORRENT_DIR" || ! mountpoint -q "$NFS_MUSIC_DIR"; then
  echo "Configurando o cliente NFS..."

  # Criando diretórios de montagem
  echo "Criando diretórios de montagem NFS..."
  sudo mkdir -p $NFS_TORRENT_DIR
  sudo mkdir -p $NFS_MUSIC_DIR

  # Montando os compartilhamentos NFS
  echo "Montando compartilhamento NFS para torrents..."
  sudo mount -t nfs "$NFS_SERVER_IP:/srv/nfs/torrent" $NFS_TORRENT_DIR || { echo "Erro ao montar o compartilhamento NFS de torrents"; exit 1; }

  echo "Montando compartilhamento NFS para músicas..."
  sudo mount -t nfs "$NFS_SERVER_IP:/srv/nfs/music" $NFS_MUSIC_DIR || { echo "Erro ao montar o compartilhamento NFS de músicas"; exit 1; }

  # Configurando a montagem automática no /etc/fstab
  echo "Configurando a montagem automática no /etc/fstab..."
  {
    echo "$NFS_SERVER_IP:/srv/nfs/torrent $NFS_TORRENT_DIR nfs defaults 0 0"
    echo "$NFS_SERVER_IP:/srv/nfs/music $NFS_MUSIC_DIR nfs defaults 0 0"
  } | sudo tee -a /etc/fstab

  echo "Montagens NFS configuradas com sucesso."
else
  echo "Cliente NFS já configurado. Nenhuma ação necessária."
fi

echo "Processo concluído com sucesso."