#!/bin/bash

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
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get autoremove -y
sudo apt-get autoclean
sudo apt-get clean
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
ExecStart=/bin/bash /bin/autoupdate

[Install]
WantedBy=multi-user.target
EOT

echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
sudo systemctl enable updateserv.service
sudo systemctl enable dns.service

sudo systemctl start updateserv.service
sudo systemctl start dns.service
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"

echo -e "\033[1;31m:=> Configurando o CSF Firewall \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
sudo apt install -y perl zip unzip libwww-perl liblwp-protocol-https-perl wget
sudo apt install -y sendmail-bin

cd /usr/src
sudo wget https://download.configserver.com/csf.tgz
sudo tar -xzvf csf.tgz
cd csf 
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

sudo csf -s