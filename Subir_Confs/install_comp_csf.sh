sudo apt-get install sendmail dnsutils unzip libio-socket-ssl-perl libcrypt-ssleay-perl git perl iptables libnet-libidn-perl libio-socket-inet6-perl libsocket6-perl -y
cd /usr/src/csf/
sudo ./install.sh
sudo systemctl enable csf