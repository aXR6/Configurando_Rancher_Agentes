# Recurso para criação das VMs sem provisionamento SSH imediato
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

# Recurso para provisionamento e configuração via SSH após a criação das VMs
resource "null_resource" "provision_vms" {
  for_each = var.virtual_machines

  depends_on = [proxmox_vm_qemu.virtual_machine] # Aguarda a criação de todas as VMs

  provisioner "remote-exec" {
    inline = [
      "echo 'notroot ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/notroot",
      "sudo chmod 0440 /etc/sudoers.d/notroot"
    ]
  }

  connection {
    type        = "ssh"
    host        = each.value.ip_address
    user        = each.value.ssh_user
    private_key = file(var.ssh_keys["priv"])
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Aguardando SSH estar disponível...'",
      "until ssh -o StrictHostKeyChecking=no -i ${var.ssh_keys["priv"]} ${each.value.ssh_user}@${each.value.ip_address} exit; do sleep 5; done",
      "echo 'SSH está disponível! Pronto para provisionamento.'"
    ]
  }

  # Provisionamento inicial com Ansible para cada VM
  provisioner "local-exec" {
    working_dir = "../ansible/"
    command     = "ansible-playbook -u ${each.value.ssh_user} --key-file ${var.ssh_keys["priv"]} -i hosts.yaml provision.yaml"
  }

  # Provisionamento para DNS-NS1
  provisioner "local-exec" {
    working_dir = "../ansible/"
    command     = "ansible-playbook -u ${each.value.ssh_user} --key-file ${var.ssh_keys["priv"]} -i indnsns1.yaml dnsns1.yaml"
  }

  # Provisionamento para DNS-NS2
  provisioner "local-exec" {
    working_dir = "../ansible/"
    command     = "ansible-playbook -u ${each.value.ssh_user} --key-file ${var.ssh_keys["priv"]} -i indnsns2.yaml dnsns2.yaml"
  }

  # Provisionamento para AGENTES
  provisioner "local-exec" {
    working_dir = "../ansible/"
    command     = "ansible-playbook -u ${each.value.ssh_user} --key-file ${var.ssh_keys["priv"]} -i agentes.yaml pb_agentes.yaml"
  }

  # Provisionamento para RANCHER
  provisioner "local-exec" {
    working_dir = "../ansible/"
    command     = "ansible-playbook -u ${each.value.ssh_user} --key-file ${var.ssh_keys["priv"]} -i rancher.yaml pb_rancher.yaml"
  }
}