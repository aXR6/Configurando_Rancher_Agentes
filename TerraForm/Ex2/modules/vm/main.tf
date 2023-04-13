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
}
 
# Define a conexão SSH para cada host
resource "null_resource" "ssh" {
  count = length(var.hosts)

  connection {
    type        = "ssh"
    host        = var.hosts[count.index]
    user        = var.ssh_user
    private_key = file(var.ssh_keys["priv"])
    agent       = false
    timeout     = "3m"
  }
}

# Executa a tarefa de provisionamento do Ansible em cada host
resource "null_resource" "provisioning" {
  count = length(var.hosts)

  provisioner "local-exec" {
    working_dir = "../ansible/"
    command = "ansible-playbook -u ${var.ssh_user} --key-file ${var.ssh_keys["priv"]} -i hosts.yaml provision.yaml"
    when = null_resource.ssh[count.index].connection_status == "success"
  }
}

# Executa a tarefa de provisionamento de DNS-NS1 em cada host
resource "null_resource" "dnsns1" {
  count = length(var.hosts)

  provisioner "local-exec" {
    working_dir = "../ansible/"
    command = "ansible-playbook -u ${var.ssh_user} --key-file ${var.ssh_keys["priv"]} -i indnsns1.yaml dnsns1.yaml"
    when = null_resource.ssh[count.index].connection_status == "success"
  }
}

# Executa a tarefa de provisionamento de DNS-NS2 em cada host
resource "null_resource" "dnsns2" {
  count = length(var.hosts)

  provisioner "local-exec" {
    working_dir = "../ansible/"
    command = "ansible-playbook -u ${var.ssh_user} --key-file ${var.ssh_keys["priv"]} -i indnsns2.yaml dnsns2.yaml"
    when = null_resource.ssh[count.index].connection_status == "success"
  }
}

# Executa a tarefa de provisionamento dos agentes em cada host
resource "null_resource" "agents" {
  count = length(var.hosts)

  provisioner "local-exec" {
    working_dir = "../ansible/"
    command = "ansible-playbook -u ${var.ssh_user} --key-file ${var.ssh_keys["priv"]} -i agentes.yaml pb_agentes.yaml"
    when = null_resource.ssh[count.index].connection_status == "success"
  }
}

# Executa a tarefa de provisionamento do Ranch
resource "null_resource" "rancher" {
  count = length(var.hosts)

  provisioner "local-exec" {
    working_dir = "../ansible/"
    command = "ansible-playbook -u ${var.ssh_user} --key-file ${var.ssh_keys["priv"]} -i rancher.yaml pb_rancher.yaml"
    when = null_resource.ssh[count.index].connection_status == "success"
  }
}