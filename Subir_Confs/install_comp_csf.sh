#sudo apt update && sudo apt-get install sendmail dnsutils unzip libio-socket-ssl-perl libcrypt-ssleay-perl git perl iptables libnet-libidn-perl libio-socket-inet6-perl libsocket6-perl -y
sudo apt update && sudo apt-get install perl iptables ipset systemd
cd /usr/src/csf/
sudo ./install.sh
sudo systemctl enable csf
sudo systemctl start csf
sudo apt autoremove -y
sudo apt autoclean

sudo csf -a 192.168.2.10 Servidor do Rancher
sudo csf -a 192.168.2.11 Primeiro agente do Rancher
sudo csf -a 192.168.2.12 Segundo agente do Rancher
sudo csf -a 192.168.2.13 Terceiro agente do Rancher
sudo csf -a 192.168.2.50 Servidor do ProxMox
sudo csf -a 192.168.2.51 Servidor do ProxMox
sudo csf -a 192.168.2.200 Servidor de DNS - NS1
sudo csf -a 192.168.2.201 Servidor de DNS - NS2
sudo csf -a 192.168.2.203 Servidor de Torrent
sudo csf -a 192.168.2.150 Máquina terminal para comendos