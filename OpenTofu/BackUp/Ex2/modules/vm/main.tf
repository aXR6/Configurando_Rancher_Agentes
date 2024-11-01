resource "tls_private_key" "virtual_machine_keys" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "proxmox_vm_qemu" "virtual_machines" {
  depends_on = [
    tls_private_key.virtual_machine_keys
  ]
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
  ssh_user         = each.value.ssh_user
  sshkeys          = tls_private_key.virtual_machine_keys.public_key_openssh
  ciuser           = each.value.ssh_user
  ipconfig0        = "ip=${each.value.ip_address}/24,gw=${each.value.gateway}"
  cipassword       = each.value.cloud_init_pass
  automatic_reboot = each.value.automatic_reboot
  nameserver       = each.value.dns_servers

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
 
  #creates ssh connection to check when the CT is ready for ansible provisioning
  connection {
    type        = "ssh"
    host        = each.value.ip_address
    user        = each.value.ssh_user
    private_key = tls_private_key.virtual_machine_keys.private_key_openssh
    agent       = false
    timeout     = "3m"
  }

  provisioner "remote-exec" {
	  # Começar com Ansible local-exec 
    inline = [ "echo 'Legal, estamos prontos para provisionamento'"]
  }

  provisioner "local-exec" {
      working_dir = "../ansible/"
      command = "ansible-playbook -i hosts.ini -u ${each.value.ssh_user} --extra-vars 'ansible_ssh_pass=${each.value.cloud_init_pass}' playbook.yaml"
     #command = "ansible-playbook -u ${each.value.ssh_user} --ask-pass -i ${each.value.ip_address} install.yaml"
  }
}