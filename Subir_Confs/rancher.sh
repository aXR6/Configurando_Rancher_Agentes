#!/bin/bash

echo -e "\033[1;31m:=> Instalando complementos necessários para o longhorn \033[0m"
echo -e "\033[1;31m:=>---------------------------------------------------------------------------------------------------------------------------\033[0m"
sudo apt update && sudo apt install -y bash curl grep mawk open-iscsi util-linux wget
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
sudo systemctl enable updateserv.service
sudo systemctl start updateserv.service