# Definindo variáveis locais fora do recurso para evitar conflitos
locals {
  ansible_playbooks = {
    "initial_provision" = "provision.yaml"
    "dns_ns1"           = "dnsns1.yaml"
    "dns_ns2"           = "dnsns2.yaml"
    "agents"            = "pb_agentes.yaml"
    "rancher"           = "pb_rancher.yaml"
  }
}

# Módulo para criação das VMs
resource "proxmox_vm_qemu" "virtual_machine" {
  for_each         = var.virtual_machines

  name             = each.value.name
  onboot           = each.value.onboot
  scsihw           = each.value.scsihw
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
  cipassword       = each.value.cloud_init_pass 
  ipconfig0        = "ip=${each.value.ip_address}/24,gw=${each.value.gateway}"
  automatic_reboot = each.value.automatic_reboot
  hotplug          = each.value.hotplug
  searchdomain     = each.value.searchdomain
  nameserver       = each.value.nameserver
  agent            = each.value.agent

  # Configuração de discos
  disk {
    type    = var.disk_type_ci
    storage = var.storage_ci
    slot    = var.slot_ci
  }

  disk {
    storage = each.value.storage_dev
    type    = each.value.disk_type
    size    = each.value.storage
    slot    = each.value.bootdisk
  }

  # Configuração de rede
  network {
    bridge   = each.value.network_bridge_type
    model    = each.value.network_model
    mtu      = 0
    macaddr  = each.value.mac_address
    queues   = 0
    rate     = 0
    firewall = each.value.network_firewall
  }
}

# Módulo para provisionamento e configuração das VMs
resource "null_resource" "provision_vms" {
  for_each = var.virtual_machines

  depends_on = [proxmox_vm_qemu.virtual_machine] # Aguarda a criação de todas as VMs

  # Configurações iniciais de sudo para o usuário
  provisioner "remote-exec" {
    inline = [
      "echo '${each.value.ssh_user} ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/${each.value.ssh_user}",
      "sudo chmod 0440 /etc/sudoers.d/${each.value.ssh_user}"
    ]
  }

  connection {
    type     = "ssh"
    host     = each.value.ip_address
    user     = each.value.ssh_user
    password = each.value.cloud_init_pass # Substitua pelo valor correspondente da senha
    timeout  = "5m"
  }

  # Executa os playbooks de provisionamento usando um único comando e diferentes inventários
  provisioner "local-exec" {
    working_dir = "../ansible/"
    command = join(" && ", [
      for playbook_name, playbook_file in local.ansible_playbooks : 
      "ansible-playbook -u ${each.value.ssh_user} -i ${playbook_name}.yaml ${playbook_file} --extra-vars 'ansible_password=${each.value.cloud_init_pass}'"
    ])
  }
}
