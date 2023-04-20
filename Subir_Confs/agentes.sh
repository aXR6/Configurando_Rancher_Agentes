#!/bin/bash

echo -e "\033[1;31m:=> Instalando complementos necessários para o longhorn \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
sudo apt update && sudo apt install -y bash curl grep mawk open-iscsi util-linux
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
echo -e "\033[1;31m:=> Configurando o CSF Firewall \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
sudo apt install -y wget libio-socket-ssl-perl perl iptables
sudo apt install -y libnet-libidn-perl libcrypt-ssleay-perl
sudo apt install -y libio-socket-inet6-perl libsocket6-perl sendmail dnsutils unzip
sudo apt autoremove -y
sudo apt autoclean

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

echo -e "\033[1;31m:=> Script para limpar containers, imagens e volumes não utilizados \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
sudo touch /bin/limparimg
sudo chmod 777 /bin/limparimg

sudo cat >'/bin/limparimg' <<EOT
docker system prune --all --force && 
docker system prune -a && 
docker volume ls -f dangling=true && 
docker volume prune &&
docker image prune --filter="label=deprecated"
EOT

echo -e "\033[1;31m:=> Startando serviços recem criados \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"

sudo docker container ls
sudo docker --version

sudo systemctl enable updateserv.service
sudo systemctl enable dns.service

sudo systemctl start updateserv.service
sudo systemctl start dns.service