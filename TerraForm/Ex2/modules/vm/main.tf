resource "proxmox_vm_qemu" "virtual_machines" {
  for_each         = var.virtual_machines
  name             = each.value.name
  qemu_os          = each.value.qemu_os
  desc             = each.value.description
  target_node      = each.value.target_node
  os_type          = each.value.os_type
  full_clone       = each.value.full_clone
  clone            = each.value.template
  vmid             = each.value.vmid
  memory           = each.value.memory
  sockets          = each.value.socket
  cores            = each.value.cores
  vcpus            = each.value.vcpus
  cpu              = each.value.cpu
  balloon          = each.value.balloon
  numa             = each.value.numa
  ssh_user         = each.value.ssh_user
  sshkeys          = file(var.ssh_keys["pub"])
  ciuser           = each.value.ssh_user
  ipconfig0        = "ip=${each.value.ip_address}/24,gw=${each.value.gateway}"
  cipassword       = each.value.cloud_init_pass
  automatic_reboot = each.value.automatic_reboot
  hotplug          = each.value.hotplug
  searchdomain     = each.value.searchdomain
  nameserver       = each.value.nameserver

  disk {
    storage = each.value.storage_dev
    type    = each.value.disk_type
    size    = each.value.storage
  }

  network {
    bridge   = each.value.network_bridge_type
    model    = each.value.network_model
    mtu      = 0
    macaddr  = each.value.mac_address
    queues   = 0
    rate     = 0
    firewall = each.value.network_firewall
  }
 
# Cria conexão SSH para verificar se a CT está pronta para o provisionamento Ansible
connection {
  type        = "ssh"
  host        = each.value.ip_address
  user        = each.value.ssh_user
  private_key = file(var.ssh_keys["priv"])
  agent       = false
  timeout     = "3m"
}

# Define caminho e comando para executar playbook Ansible
locals {
  playbook_dir = "../ansible/"
  ansible_cmd  = "ansible-playbook -u ${each.value.ssh_user} --key-file ${var.ssh_keys["priv"]}"
}

# Executa playbook Ansible para padronização das máquinas
provisioner "local-exec" {
  working_dir = local.playbook_dir
  command = "${local.ansible_cmd} -i hosts.yaml provision.yaml && \
             ${local.ansible_cmd} -i indnsns1.yaml dnsns1.yaml && \
             ${local.ansible_cmd} -i indnsns2.yaml dnsns2.yaml && \
             ${local.ansible_cmd} -i agentes.yaml pb_agentes.yaml && \
             ${local.ansible_cmd} -i rancher.yaml pb_rancher.yaml"
}
}