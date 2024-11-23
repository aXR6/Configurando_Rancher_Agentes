#!/bin/bash

# Função para exibir mensagem de erro e sair
function erro() {
    echo -e "[ERRO] $1"
    exit 1
}

# Verifica se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
    erro "Este script precisa ser executado como root."
fi

# Solicita o nome do nó ou cluster para remoção
read -p "Digite o nome do nó que deseja remover do cluster ou 'all' para remover o cluster completo: " node_name

# Verifica se o sistema está em um cluster
if [ ! -f "/etc/pve/.members" ]; then
    erro "Este sistema não está configurado como parte de um cluster."
fi

# Confirmação adicional do usuário
read -p "Você tem certeza que deseja prosseguir com a remoção? Esta ação pode ser irreversível! [s/N]: " confirm
if [[ "$confirm" != "s" && "$confirm" != "S" ]]; then
    echo "Operação cancelada pelo usuário."
    exit 0
fi

# Remoção de um nó específico
if [[ "$node_name" != "all" ]]; then
    echo "Removendo o nó '$node_name' do cluster..."
    pvecm delnode "$node_name" || erro "Falha ao remover o nó '$node_name'. Verifique o nome ou status do cluster."
    echo "Nó '$node_name' removido com sucesso do cluster."
    exit 0
fi

# Remoção completa do cluster
echo "Removendo todos os nós e desmantelando o cluster..."

# Parar o serviço do cluster
echo "Parando serviços relacionados ao cluster..."
systemctl stop pve-cluster corosync || erro "Falha ao parar os serviços de cluster."

# Remover arquivos de configuração do cluster
echo "Removendo configurações do cluster..."
rm -rf /etc/corosync /etc/pve/corosync.conf /var/lib/corosync/* || erro "Falha ao remover os arquivos de configuração do cluster."

# Reiniciar o serviço pve-cluster
echo "Reiniciando os serviços para restaurar o estado standalone..."
systemctl restart pve-cluster || erro "Falha ao reiniciar o serviço pve-cluster."

echo "Cluster desmontado com sucesso. O nó está agora em estado standalone."
exit 0