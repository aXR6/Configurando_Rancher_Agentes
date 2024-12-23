#!/bin/bash

# Função para exibir o menu principal
show_menu() {
    clear
    echo "======================================="
    echo "         Segurança do Servidor"
    echo "           Debian 12 Automação"
    echo "======================================="
    echo "1. Atualizar o sistema"
    echo "2. Configurar usuário e SSH"
    echo "3. Instalar Fail2Ban"
    echo "4. Configurar sysctl para segurança"
    echo "5. Monitoramento e logs"
    echo "6. Backup básico (rsync)"
    echo "7. Instalar Lynis para auditoria"
    echo "8. Configurar GRUB com senha"
    echo "0. Sair"
    echo "======================================="
    echo -n "Escolha uma opção: "
}

# Função para atualizar o sistema
update_system() {
    echo "Atualizando o sistema..."
    apt update && apt upgrade -y
    apt install unattended-upgrades -y
    dpkg-reconfigure -plow unattended-upgrades
    echo "Sistema atualizado e atualizações automáticas configuradas."
    read -p "Pressione Enter para continuar..."
}

# Função para configurar usuário e SSH
configure_user_ssh() {
    echo -n "Digite o nome do novo usuário: "
    read new_user
    useradd -m -s /bin/bash "$new_user"
    passwd "$new_user"
    echo "Usuário criado."
    
    echo "Configurando SSH..."
    sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config
    systemctl restart ssh
    echo "SSH configurado na porta 2222. Root login desativado."
    read -p "Pressione Enter para continuar..."
}

# Função para instalar Fail2Ban
install_fail2ban() {
    echo "Instalando Fail2Ban..."
    apt install fail2ban -y
    systemctl enable fail2ban
    systemctl start fail2ban
    echo "Fail2Ban instalado e ativado."
    read -p "Pressione Enter para continuar..."
}

# Função para configurar sysctl
configure_sysctl() {
    echo "Configurando parâmetros de segurança do kernel..."
    cat <<EOL >> /etc/sysctl.conf
net.ipv4.ip_forward = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1
kernel.dmesg_restrict = 1
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv4.tcp_max_syn_backlog = 2048
EOL
    sysctl -p
    echo "Parâmetros de segurança aplicados."
    read -p "Pressione Enter para continuar..."
}

# Função para configurar monitoramento e logs
configure_monitoring_logs() {
    echo "Instalando ferramentas de monitoramento..."
    apt install htop iotop nload logwatch auditd -y
    systemctl enable auditd
    systemctl start auditd
    echo "Ferramentas de monitoramento instaladas."
    read -p "Pressione Enter para continuar..."
}

# Função para configurar backup com rsync
configure_backup() {
    echo -n "Digite o diretório a ser backupado: "
    read backup_dir
    echo -n "Digite o destino do backup (exemplo: user@host:/path): "
    read backup_dest
    rsync -avz "$backup_dir" "$backup_dest"
    echo "Backup realizado com rsync."
    read -p "Pressione Enter para continuar..."
}

# Função para instalar Lynis
install_lynis() {
    echo "Instalando Lynis..."
    apt install lynis -y
    echo "Lynis instalado. Para auditoria, execute: lynis audit system"
    read -p "Pressione Enter para continuar..."
}

# Função para configurar senha no GRUB
configure_grub() {
    echo "Configurando senha no GRUB..."
    grub_password=$(grub-mkpasswd-pbkdf2 | grep -oP '(?<=hash:\s).*')
    echo -n "set superusers=\"root\"" >> /etc/grub.d/40_custom
    echo -n "password_pbkdf2 root $grub_password" >> /etc/grub.d/40_custom
    update-grub
    echo "Senha do GRUB configurada."
    read -p "Pressione Enter para continuar..."
}

# Loop do menu
while true; do
    show_menu
    read option
    case $option in
        1) update_system ;;
        2) configure_user_ssh ;;
        3) install_fail2ban ;;
        4) configure_sysctl ;;
        5) configure_monitoring_logs ;;
        6) configure_backup ;;
        7) install_lynis ;;
        8) configure_grub ;;
        0) echo "Saindo..."; exit ;;
        *) echo "Opção inválida!"; sleep 2 ;;
    esac
done