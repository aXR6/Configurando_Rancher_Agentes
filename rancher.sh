#!/bin/bash

echo -e "\033[1;31m:=> Instalando complementos necessários para o longhorn \033[0m"
---------------------------------------------------------------------------------------------------------------------------
apt install -y bash curl grep mawk open-iscsi util-linux
---------------------------------------------------------------------------------------------------------------------------

echo -e "\033[1;31m:=> Criando o arquivo de configuração: RESOLVER \033[0m"
---------------------------------------------------------------------------------------------------------------------------
touch /bin/resolver
chmod 777 /bin/resolver

cat >'/bin/resolver' <<EOT

cat >'/etc/resolv.conf' <<EOT
search pve.datacenter.tsc
nameserver 192.168.2.200
nameserver 192.168.2.201
nameserver 192.168.2.254
nameserver 8.8.8.8
EOT

EOT
---------------------------------------------------------------------------------------------------------------------------

echo -e "\033[1;31m:=> Configurando o serviço que iniciará o RESOLVER \033[0m"
---------------------------------------------------------------------------------------------------------------------------
touch /lib/systemd/system/dns.service
chmod 777 /lib/systemd/system/dns.service

cat >'/lib/systemd/system/dns.service' <<EOT
[Unit]
Description=Padronizacao das configuracoes de DNS do Datacenter.

[Service]
Type=simple
User=root
ExecStart=/bin/bash /bin/resolver

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl enable dns.service
systemctl start dns.service
---------------------------------------------------------------------------------------------------------------------------

echo -e "\033[1;31m:=> Criando o arquivo: AUTOUPDATE \033[0m"
---------------------------------------------------------------------------------------------------------------------------
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
---------------------------------------------------------------------------------------------------------------------------

echo -e "\033[1;31m:=> Configurando o serviço que iniciará o AUTOUPDATE \033[0m"
---------------------------------------------------------------------------------------------------------------------------
touch /lib/systemd/system/updateserv.service
chmod 777 /lib/systemd/system/updateserv.service

cat >'/lib/systemd/system/updateserv.service' <<EOT
[Unit]
Description=Atualiza a distribuição Linux

[Service]
Type=simple
ExecStart=/bin/bash /bin/autoupdate

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl enable updateserv.service
systemctl start updateserv.service
---------------------------------------------------------------------------------------------------------------------------

echo -e "\033[1;31m:=> Preparando o ambiente e instalando o Docker \033[0m"
---------------------------------------------------------------------------------------------------------------------------
clear && apt update && apt dist-upgrade -y && apt autoremove -y && apt autoclean && curl https://releases.rancher.com/install-docker/20.10.sh | sh && usermod -aG docker root
---------------------------------------------------------------------------------------------------------------------------

echo -e "\033[1;31m:=> Preparando o ambiente e instalando o helm \033[0m"
---------------------------------------------------------------------------------------------------------------------------
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null && 
apt-get install apt-transport-https --yes && 
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list && 
apt-get update && 
apt-get install helm
---------------------------------------------------------------------------------------------------------------------------

echo -e "\033[1;31m:=> Preparando o ambiente e instalando o rancher \033[0m"
---------------------------------------------------------------------------------------------------------------------------
docker run --privileged -d --restart=unless-stopped -v dbrancher:/var/lib/rancher -p 80:80 -p 443:443 rancher/rancher
---------------------------------------------------------------------------------------------------------------------------

echo -e "\033[1;31m:=> Preparando o ambiente e instalando o kubectl \033[0m"
---------------------------------------------------------------------------------------------------------------------------
apt-get update && 
apt-get install -y ca-certificates curl && 
apt-get install -y apt-transport-https && 
curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg && 
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list && 
apt-get update && 
apt-get install -y kubectl
---------------------------------------------------------------------------------------------------------------------------

echo -e "\033[1;31m:=> Preparando o ambiente e configurando o mapeamento no NFS \033[0m"
---------------------------------------------------------------------------------------------------------------------------
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
---------------------------------------------------------------------------------------------------------------------------

echo -e "\033[1;31m:=> Script para limpar containers, imagens e volumes não utilizados \033[0m"
---------------------------------------------------------------------------------------------------------------------------
touch /bin/limparimg
chmod 777 /bin/limparimg

cat >'/bin/limparimg' <<EOT
docker system prune --all --force && 
docker system prune -a && 
docker volume ls -f dangling=true && 
docker volume prune &&
docker image prune --filter="label=deprecated"
EOT
---------------------------------------------------------------------------------------------------------------------------