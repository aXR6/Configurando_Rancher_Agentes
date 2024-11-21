#!/bin/bash

# Script para desbloquear e apagar VMs

# Log file
log_file="/var/log/unlock_remove_vms.log"
exec > >(tee -a "$log_file") 2>&1

# Função para verificar dependências
check_dependencies() {
    for cmd in qm grep pvesh jq; do
        if ! command -v $cmd &>/dev/null; then
            echo "Erro: $cmd não está instalado. Por favor, instale-o antes de executar este script."
            exit 1
        fi
    done
}

# Função para desbloquear VMs
unlock_vm() {
    local vmid=$1
    echo "Verificando se a VM ID: $vmid está bloqueada."
    if qm status $vmid | grep -q "locked"; then
        echo "Desbloqueando VM ID: $vmid."
        if ! qm unlock $vmid; then
            echo "Falha ao desbloquear VM ID: $vmid. Pulando remoção."
            return 1
        fi
    else
        echo "VM ID: $vmid não está bloqueada. Prosseguindo."
    fi
}

# Função para remover discos associados a uma VM
remove_disks() {
    local vmid=$1
    echo "Removendo discos da VM ID: $vmid."
    local disks=$(pvesh get /nodes/$(hostname)/qemu/$vmid/config | jq -r '.disks[]?.file')

    if [[ -z "$disks" ]]; then
        echo "Nenhum disco encontrado para a VM ID: $vmid."
        return 0
    fi

    for disk in $disks; do
        echo "Removendo disco: $disk."
        if ! qm disk-remove $vmid $disk --force; then
            echo "Falha ao remover o disco $disk da VM ID: $vmid. Verifique manualmente."
        fi
    done
}

# Função para remover uma VM
remove_vm() {
    local vmid=$1

    echo "Verificando o status da VM ID: $vmid."
    if qm status $vmid | grep -q "running"; then
        echo "Parando a VM ID: $vmid."
        qm stop $vmid
        sleep 5
    fi

    remove_disks $vmid

    echo "Removendo a VM ID: $vmid com configurações."
    if ! qm destroy $vmid --purge --destroy-unreferenced-disks; then
        echo "Falha ao remover a VM ID: $vmid. Tentando novamente."
        sleep 2
        if ! qm destroy $vmid --purge --destroy-unreferenced-disks; then
            echo "Falha permanente ao remover a VM ID: $vmid. Verifique os logs."
            return 1
        fi
    fi
}

# Função principal para listar e processar as VMs bloqueadas
process_locked_vms() {
    local locked_vms=($(qm list | awk '/locked/ {print $1}'))

    if [[ ${#locked_vms[@]} -eq 0 ]]; then
        echo "Nenhuma VM bloqueada encontrada."
        return 0
    fi

    for vmid in "${locked_vms[@]}"; do
        echo "Processando VM ID: $vmid."
        if unlock_vm $vmid; then
            if remove_vm $vmid; then
                echo "VM ID: $vmid removida com sucesso."
            fi
        fi
        echo "---"
    done
}

# Início do script
echo "Script iniciado em $(date)."
check_dependencies
process_locked_vms
echo "Processo concluído em $(date)."