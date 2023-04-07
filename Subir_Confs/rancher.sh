#!/bin/bash

echo -e "\033[1;31m:=> Instalando complementos necessários para o longhorn \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
apt update && apt install -y bash curl grep mawk open-iscsi util-linux cloud-init
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"

echo -e "\033[1;31m:=> Criando o arquivo de configuração: RESOLVER \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
touch /bin/resolver
chmod 777 /bin/resolver

cat >'/bin/resolver' <<EOT

cat >'/etc/resolv.conf' <<EOT
search pve.datacenter.tsc
nameserver 192.168.2.200
nameserver 192.168.2.201
nameserver 192.168.2.254
nameserver 8.8.8.8 EOT

EOT
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"

echo -e "\033[1;31m:=> Configurando o serviço que iniciará o RESOLVER \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
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

echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"

echo -e "\033[1;31m:=> Criando o arquivo: AUTOUPDATE \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
touch /bin/autoupdate
chmod 777 /bin/autoupdate
cat >'/bin/autoupdate' <<EOT
#!/bin/bash

# Função que atualiza a distribuição Debian
update_debian() {
  apt-get update
  apt-get upgrade -y
  apt-get autoremove -y
  apt-get autoclean
  apt-get clean
}

# Função que atualiza a distribuição Debian sem atualizar o Docker
update_debian_without_docker() {
  apt-mark hold docker-ce docker-ce-cli containerd.io docker-buildx-plugin
  apt-get update
  apt-get upgrade -y
  apt-get autoremove -y
  apt-get autoclean
  apt-get clean
  apt-mark unhold docker-ce docker-ce-cli containerd.io docker-buildx-plugin
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
touch /lib/systemd/system/updateserv.service
chmod 777 /lib/systemd/system/updateserv.service

cat >'/lib/systemd/system/updateserv.service' <<EOT
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
curl https://releases.rancher.com/install-docker/20.10.sh | sh
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"

echo -e "\033[1;31m:=> Preparando o ambiente e instalando o rancher \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
docker run --name rancher --privileged -d --restart=unless-stopped -v dbrancher:/var/lib/rancher -p 80:80 -p 443:443 rancher/rancher
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"

echo -e "\033[1;31m:=> Preparando o ambiente e instalando o kubectl \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
apt-get update && 
apt-get install -y ca-certificates curl && 
apt-get install -y apt-transport-https && 
curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg && 
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list && 
apt-get update && 
apt-get install -y kubectl
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"

echo -e "\033[1;31m:=> Preparando o ambiente e instalando o helm \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null && 
apt-get install apt-transport-https --yes && 
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list && 
apt-get update && 
apt-get install helm
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"

echo -e "\033[1;31m:=> Preparando o ambiente e configurando o mapeamento no NFS \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
apt install -y nfs-common

mkdir /home/nextcloud
mkdir /home/torrent

cp /etc/fstab /etc/fstab.bak
cat >'/etc/fstab' <<EOT
192.168.2.202:/home/nextcloud /home/nextcloud nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
192.168.2.203:/home/torrent /home/torrent nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
EOT

# mount 192.168.2.202:/home/nextcloud /home/nextcloud
# mount 192.168.2.203:/home/torrent /home/torrent
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"

echo -e "\033[1;31m:=> Script para limpar containers, imagens e volumes não utilizados \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
touch /bin/limparimg
chmod 777 /bin/limparimg

cat >'/bin/limparimg' <<EOT
docker system prune --all --force && 
docker system prune -a && 
docker volume ls -f dangling=true && 
docker volume prune &&
docker image prune --filter="label=deprecated"
EOT

echo -e "\033[1;31m:=> Criando o arquivo de configuração para o KubeCTL \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
mkdir ~/.kube
touch ~/.kube/config

echo -e "\033[1;31m:=> Startando serviços recem criados \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
#systemctl daemon-reload

systemctl enable updateserv.service &&
systemctl enable dns.service &&

systemctl start updateserv.service &&
systemctl start dns.service
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