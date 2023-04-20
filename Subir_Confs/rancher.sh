#!/bin/bash

echo -e "\033[1;31m:=> Instalando complementos necessários para o longhorn \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
sudo apt update && sudo apt install -y bash curl grep mawk open-iscsi util-linux wget
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"

echo -e "\033[1;31m:=> Criando o arquivo de configuração: RESOLVER \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
sudo touch /bin/resolver
sudo chmod 777 /bin/resolver

sudo cat >'/bin/resolver' <<EOT

cat >'/etc/resolv.conf' <<EOT
search pve.datacenter.tsc
nameserver 192.168.2.200
nameserver 192.168.2.201
nameserver 192.168.2.254
nameserver 8.8.8.8
EOT

EOT
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"

echo -e "\033[1;31m:=> Configurando o serviço que iniciará o RESOLVER \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
sudo touch /lib/systemd/system/dns.service
sudo chmod 777 /lib/systemd/system/dns.service

sudo cat >'/lib/systemd/system/dns.service' <<EOT
[Unit]
Description=Padronizacao das configuracoes de DNS do Datacenter.

[Service]
Type=simple
User=root
ExecStart=/bin/bash /bin/resolver

[Install]
WantedBy=multi-user.target
EOT

echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"

echo -e "\033[1;31m:=> Criando o arquivo: AUTOUPDATE \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
sudo touch /bin/autoupdate
sudo chmod 777 /bin/autoupdate
sudo cat >'/bin/autoupdate' <<EOT
#!/bin/bash

# Função que atualiza a distribuição Debian
update_debian() {
  sudo apt-get update
  sudo apt-get upgrade -y
  sudo apt-get autoremove -y
  sudo apt-get autoclean
  sudo apt-get clean
}

# Função que atualiza a distribuição Debian sem atualizar o Docker
update_debian_without_docker() {
  sudo apt-mark hold docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-ce-rootless-extras
  sudo apt-get update
  sudo apt-get upgrade -y
  sudo apt-get autoremove -y
  sudo apt-get autoclean
  sudo apt-get clean
  sudo apt-mark unhold docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-ce-rootless-extras
}

# Verifica se o usuário deseja atualizar a distribuição sem atualizar o Docker
if [ "$1" == "--without-docker" ]; then
  update_debian_without_docker
else
  update_debian
fi
EOT
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"

echo -e "\033[1;31m:=> Configurando o serviço que iniciará o AUTOUPDATE \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
sudo touch /lib/systemd/system/updateserv.service
sudo chmod 777 /lib/systemd/system/updateserv.service

sudo cat >'/lib/systemd/system/updateserv.service' <<EOT
[Unit]
Description=Atualiza a distribuição Linux

[Service]
Type=simple
ExecStart=/bin/bash /bin/autoupdate --without-docker

#./autoupdate                  # atualiza a distribuição normalmente
#./autoupdate --without-docker # atualiza a distribuição sem atualizar o Docker

[Install]
WantedBy=multi-user.target
EOT

echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"

echo -e "\033[1;31m:=> Preparando o ambiente e instalando o Docker \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
sudo curl https://releases.rancher.com/install-docker/20.10.sh | sh
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"

echo -e "\033[1;31m:=> Preparando o ambiente e instalando o rancher \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
sudo docker run --name rancher --privileged -d --restart=unless-stopped -v dbrancher:/var/lib/rancher -p 80:80 -p 443:443 rancher/rancher
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"

echo -e "\033[1;31m:=> Preparando o ambiente e instalando o kubectl \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
sudo apt-get update && 
sudo apt-get install -y ca-certificates curl && 
sudo apt-get install -y apt-transport-https && 
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg && 
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo  tee /etc/apt/sources.list.d/kubernetes.list && 
sudo apt-get update && 
sudo apt-get install -y kubectl
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"

echo -e "\033[1;31m:=> Preparando o ambiente e instalando o helm \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
sudo curl https://baltocdn.com/helm/signing.asc | sudo gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null && 
sudo apt-get install apt-transport-https --yes && 
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list && 
sudo apt-get update && 
sudo apt-get install helm
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"

echo -e "\033[1;31m:=> Script para limpar containers, imagens e volumes não utilizados \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
sudo touch /bin/limparimg
sudo chmod 777 /bin/limparimg

sudo cat >'/bin/limparimg' <<EOT
sudo docker system prune --all --force && 
sudo docker system prune -a && 
sudo docker volume ls -f dangling=true && 
sudo docker volume prune &&
sudo docker image prune --filter="label=deprecated"
EOT

echo -e "\033[1;31m:=> Criando o arquivo de configuração para o KubeCTL \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
sudo mkdir ~/.kube
sudo touch ~/.kube/config

echo -e "\033[1;31m:=> Startando serviços recem criados \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
#sudo systemctl daemon-reload

sudo systemctl enable updateserv.service &&
sudo systemctl enable dns.service &&

sudo systemctl start updateserv.service &&
sudo systemctl start dns.service
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"

echo -e "\033[1;31m:=> Capturando a chave do Rancher \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
# Lista os containers em execução
containers=$(docker ps --format "{{.ID}}\t{{.Names}}")

# Imprime a lista de containers
echo "Containers em execução:"
echo "$containers"

# Pede ao usuário para digitar o nome do container
nome_container="rancher"

# Obtém o hash do container com o nome especificado
hash_container=$(echo "$containers" | grep "$nome_container" | cut -f1)

# Verifica se o container foi encontrado
if [ -z "$hash_container" ]; then
  echo "O container '$nome_container' não foi encontrado."
  exit 1
fi

# Imprime o hash do container encontrado
echo "Encontre o ID do contêiner '$nome_container' com a seguinte hash $hash_container"

echo -e "\033[1;31m:=> Configurando o CSF Firewall \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
sudo apt install -y perl zip unzip libwww-perl liblwp-protocol-https-perl wget
sudo apt install -y sendmail-bin

sudo wget https://download.configserver.com/csf.tgz -P /usr/src
sudo tar -xvzf /usr/src/csf.tgz
cd /usr/src/csf
sudo sh install.sh

sudo perl /usr/local/csf/bin/csftest.pl

sudo cat >'/etc/csf/csf.conf' <<EOT
# Configurações de Firewall csf

# Habilitar o csf
TESTING = "0"
# Alterar para "1" para executar no modo de teste sem bloquear
# Alterar para "0" para executar no modo de produção

# Lista de portas TCP permitidas
TCP_IN = "20,21,22,25,53,80,110,143,443,465,587,993,995"
TCP_OUT = "20,21,22,25,53,80,110,113,443"

# Lista de portas UDP permitidas
UDP_IN = "53"
UDP_OUT = "20,21,53"

# Proteger contra ataques SYN
SYN_ATTACK = "1"

# Proteger contra ataques de portas aleatórias
PORTFLOOD = "80;tcp;20;5"

# Proteger contra ataque DDoS
DDOS = "1"

# Proteger contra ataques de bruteforce SSH
LF_SSHD = "5"

# Proteger contra ataques de bruteforce FTP
LF_FTPD = "5"

# Proteger contra ataques de bruteforce POP3
LF_POP3D = "5"

# Proteger contra ataques de bruteforce IMAP
LF_IMAPD = "5"

# Proteger contra ataques de bruteforce SFTP
LF_SFTPD = "5"

# Proteger contra ataques de bruteforce Exim
LF_EXIMSYNTAX = "5"

# Proteger contra ataques de bruteforce cPanel
LF_CPANEL = "5"

# Proteger contra ataques de bruteforce WHM
LF_CPANEL = "5"

# Bloquear IPs mal-intencionados
DROP_IPS = "1"

# Proteger contra o uso malicioso de executáveis PHP
PHP_FPM = "1"

# Permitir conexões SSL
CT_LIMIT = "80;300;5/300;6"
EOT

sudo csf -a 192.168.2.10
sudo csf -a 192.168.2.11
sudo csf -a 192.168.2.12
sudo csf -a 192.168.2.13
sudo csf -a 192.168.2.200
sudo csf -a 192.168.2.201
sudo csf -a 192.168.2.203
sudo csf -a 192.168.2.150

sudo csf -s