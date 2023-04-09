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
nameserver 8.8.8.8 EOT

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
  sudo apt-mark hold docker-ce docker-ce-cli containerd.io docker-buildx-plugin
  sudo apt-get update
  sudo apt-get upgrade -y
  sudo apt-get autoremove -y
  sudo apt-get autoclean
  sudo apt-get clean
  sudo apt-mark unhold docker-ce docker-ce-cli containerd.io docker-buildx-plugin
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
sudo systemctl enable updateserv.service &&
sudo systemctl enable dns.service &&

sudo systemctl start updateserv.service &&
sudo systemctl start dns.service