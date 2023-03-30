#!/bin/bash

echo -e "\033[1;31m:=> Instalando complementos necessários para o longhorn \033[0m"
-----------------------------------------
apt install -y bash curl grep mawk open-iscsi util-linux
-----------------------------------------

echo -e "\033[1;31m:=> Criando o arquivo de configuração: RESOLVER \033[0m"
-----------------------------------------
touch /bin/resolver
chmod 777 /bin/resolver

cat >'/etc/resolv.conf' <<EOT
search pve.datacenter.tsc
nameserver 192.168.2.200
nameserver 192.168.2.201
nameserver 192.168.2.254
nameserver 8.8.8.8
EOT
-----------------------------------------

echo -e "\033[1;31m:=> Configurando o serviço que iniciará o RESOLVER \033[0m"
-----------------------------------------
touch /lib/systemd/system/dns.service
chmod 777 /lib/systemd/system/dns.service

cat >'/lib/systemd/system/dns.service' <<EOT
[Unit]
Description=Padronizacao das configuracoes de DNS do Datacenter.
#After=network-online.target
#Wants=network-online.target

[Service]
Type=simple
User=root
ExecStart=/bin/bash /bin/resolver
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl enable dns.service
systemctl start dns.service
-----------------------------------------

echo -e "\033[1;31m:=> Criando o arquivo: AUTOUPDATE \033[0m"
-----------------------------------------
touch /bin/autoupdate
chmod 777 /bin/autoupdate
cat >'/bin/autoupdate' <<EOT
#!/bin/bash

# Atualiza a lista de pacotes disponíveis
sudo apt update

# Atualiza os pacotes instalados para a versão mais recente
sudo apt upgrade -y

# Remove pacotes que não são mais necessários
sudo apt autoremove -y

# Limpa o cache dos pacotes baixados anteriormente
sudo apt clean

# Exibe uma mensagem informando que a atualização foi concluída com sucesso
echo "Atualização concluída com sucesso em $(date +"%d/%m/%Y às %H:%M:%S")"

exit 0
EOT
-----------------------------------------

echo -e "\033[1;31m:=> Configurando o serviço que iniciará o AUTOUPDATE \033[0m"
-----------------------------------------
touch /lib/systemd/system/updateserv.service
chmod 777 /lib/systemd/system/updateserv.service

cat >'/lib/systemd/system/updateserv.service' <<EOT
[Unit]
Description=Atualiza a distribuição Linux

[Service]
Type=simple
ExecStart=/lib/systemd/system/autoupdate.service

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl enable updateserv.service
systemctl start updateserv.service
-----------------------------------------

echo -e "\033[1;31m:=> Preparando o ambiente e instalando o Docker \033[0m"
-----------------------------------------
clear && apt update && apt dist-upgrade -y && apt autoremove -y && apt autoclean && curl https://releases.rancher.com/install-docker/20.10.sh | sh && usermod -aG docker root
-----------------------------------------

echo -e "\033[1;31m:=> Preparando o ambiente e configurando o mapeamento no NFS \033[0m"
-----------------------------------------
apt install -y nfs-common

mkdir /home/nextcloud
mkdir /home/torrent

cp /etc/fstab /etc/fstab.bak
cat >'/etc/fstab' <<EOT
192.168.2.202:/home/nextcloud /home/nextcloud nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
192.168.2.203:/home/torrent /home/torrent nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
EOT

mount 192.168.2.202:/home/nextcloud /home/nextcloud
mount 192.168.2.203:/home/torrent /home/torrent
-----------------------------------------

echo -e "\033[1;31m:=> Script para limpar containers, imagens e volumes não utilizados \033[0m"
-----------------------------------------
touch /bin/limparimg
chmod 777 /bin/limparimg

cat >'/bin/limparimg' <<EOT
docker system prune --all --force && 
docker system prune -a && 
docker volume ls -f dangling=true && 
docker volume prune &&
docker image prune --filter="label=deprecated"
EOT
-----------------------------------------