# Recurso para criação das VMs sem provisionamento SSH imediato
# Definição de cada VM de forma individual para aplicar dependências explícitas
resource "proxmox_vm_qemu" "vm1" {
  name             = var.virtual_machines["m1"].name
  onboot           = var.virtual_machines["m1"].onboot
  scsihw           = var.virtual_machines["m1"].scsihw
  qemu_os          = var.virtual_machines["m1"].qemu_os
  desc             = var.virtual_machines["m1"].description
  target_node      = var.virtual_machines["m1"].target_node
  os_type          = var.virtual_machines["m1"].os_type
  full_clone       = var.virtual_machines["m1"].full_clone
  clone            = var.virtual_machines["m1"].template
  vmid             = var.virtual_machines["m1"].vmid
  memory           = var.virtual_machines["m1"].memory
  sockets          = var.virtual_machines["m1"].socket
  cores            = var.virtual_machines["m1"].cores
  vcpus            = var.virtual_machines["m1"].vcpus
  cpu              = var.virtual_machines["m1"].cpu
  balloon          = var.virtual_machines["m1"].balloon
  numa             = var.virtual_machines["m1"].numa
  ssh_user         = var.virtual_machines["m1"].ssh_user
  sshkeys          = file(var.ssh_keys["pub"])
  ciuser           = var.virtual_machines["m1"].ssh_user
  cipassword       = var.virtual_machines["m1"].cloud_init_pass
  ipconfig0        = "ip=${var.virtual_machines["m1"].ip_address}/24,gw=${var.virtual_machines["m1"].gateway}"
  automatic_reboot = var.virtual_machines["m1"].automatic_reboot
  hotplug          = var.virtual_machines["m1"].hotplug
  searchdomain     = var.virtual_machines["m1"].searchdomain
  nameserver       = var.virtual_machines["m1"].nameserver
  agent            = var.virtual_machines["m1"].agent

  disk {
    type    = var.disk_type_ci
    storage = var.storage_ci
    slot    = var.slot_ci
  }

  disk {
    storage = var.virtual_machines["m1"].storage_dev
    type    = var.virtual_machines["m1"].disk_type
    size    = var.virtual_machines["m1"].storage
    slot    = var.virtual_machines["m1"].bootdisk
  }

  network {
    bridge   = var.virtual_machines["m1"].network_bridge_type
    model    = var.virtual_machines["m1"].network_model
    mtu      = 0
    macaddr  = var.virtual_machines["m1"].mac_address
    queues   = 0
    rate     = 0
    firewall = var.virtual_machines["m1"].network_firewall
  }
}

resource "proxmox_vm_qemu" "vm2" {
  name             = var.virtual_machines["m2"].name
  onboot           = var.virtual_machines["m2"].onboot
  scsihw           = var.virtual_machines["m2"].scsihw
  qemu_os          = var.virtual_machines["m2"].qemu_os
  desc             = var.virtual_machines["m2"].description
  target_node      = var.virtual_machines["m2"].target_node
  os_type          = var.virtual_machines["m2"].os_type
  full_clone       = var.virtual_machines["m2"].full_clone
  clone            = var.virtual_machines["m2"].template
  vmid             = var.virtual_machines["m2"].vmid
  memory           = var.virtual_machines["m2"].memory
  sockets          = var.virtual_machines["m2"].socket
  cores            = var.virtual_machines["m2"].cores
  vcpus            = var.virtual_machines["m2"].vcpus
  cpu              = var.virtual_machines["m2"].cpu
  balloon          = var.virtual_machines["m2"].balloon
  numa             = var.virtual_machines["m2"].numa
  ssh_user         = var.virtual_machines["m2"].ssh_user
  sshkeys          = file(var.ssh_keys["pub"])
  ciuser           = var.virtual_machines["m2"].ssh_user
  cipassword       = var.virtual_machines["m2"].cloud_init_pass
  ipconfig0        = "ip=${var.virtual_machines["m2"].ip_address}/24,gw=${var.virtual_machines["m2"].gateway}"
  automatic_reboot = var.virtual_machines["m2"].automatic_reboot
  hotplug          = var.virtual_machines["m2"].hotplug
  searchdomain     = var.virtual_machines["m2"].searchdomain
  nameserver       = var.virtual_machines["m2"].nameserver
  agent            = var.virtual_machines["m2"].agent

  disk {
    type    = var.disk_type_ci
    storage = var.storage_ci
    slot    = var.slot_ci
  }

  disk {
    storage = var.virtual_machines["m2"].storage_dev
    type    = var.virtual_machines["m2"].disk_type
    size    = var.virtual_machines["m2"].storage
    slot    = var.virtual_machines["m2"].bootdisk
  }

  network {
    bridge   = var.virtual_machines["m2"].network_bridge_type
    model    = var.virtual_machines["m2"].network_model
    mtu      = 0
    macaddr  = var.virtual_machines["m2"].mac_address
    queues   = 0
    rate     = 0
    firewall = var.virtual_machines["m2"].network_firewall
  }

  depends_on = [proxmox_vm_qemu.vm1]
}
resource "proxmox_vm_qemu" "vm3" {
  name             = var.virtual_machines["m3"].name
  onboot           = var.virtual_machines["m3"].onboot
  scsihw           = var.virtual_machines["m3"].scsihw
  qemu_os          = var.virtual_machines["m3"].qemu_os
  desc             = var.virtual_machines["m3"].description
  target_node      = var.virtual_machines["m3"].target_node
  os_type          = var.virtual_machines["m3"].os_type
  full_clone       = var.virtual_machines["m3"].full_clone
  clone            = var.virtual_machines["m3"].template
  vmid             = var.virtual_machines["m3"].vmid
  memory           = var.virtual_machines["m3"].memory
  sockets          = var.virtual_machines["m3"].socket
  cores            = var.virtual_machines["m3"].cores
  vcpus            = var.virtual_machines["m3"].vcpus
  cpu              = var.virtual_machines["m3"].cpu
  balloon          = var.virtual_machines["m3"].balloon
  numa             = var.virtual_machines["m3"].numa
  ssh_user         = var.virtual_machines["m3"].ssh_user
  sshkeys          = file(var.ssh_keys["pub"])
  ciuser           = var.virtual_machines["m3"].ssh_user
  cipassword       = var.virtual_machines["m3"].cloud_init_pass
  ipconfig0        = "ip=${var.virtual_machines["m3"].ip_address}/24,gw=${var.virtual_machines["m3"].gateway}"
  automatic_reboot = var.virtual_machines["m3"].automatic_reboot
  hotplug          = var.virtual_machines["m3"].hotplug
  searchdomain     = var.virtual_machines["m3"].searchdomain
  nameserver       = var.virtual_machines["m3"].nameserver
  agent            = var.virtual_machines["m3"].agent

  disk {
    type    = var.disk_type_ci
    storage = var.storage_ci
    slot    = var.slot_ci
  }

  disk {
    storage = var.virtual_machines["m3"].storage_dev
    type    = var.virtual_machines["m3"].disk_type
    size    = var.virtual_machines["m3"].storage
    slot    = var.virtual_machines["m3"].bootdisk
  }

  network {
    bridge   = var.virtual_machines["m3"].network_bridge_type
    model    = var.virtual_machines["m3"].network_model
    mtu      = 0
    macaddr  = var.virtual_machines["m3"].mac_address
    queues   = 0
    rate     = 0
    firewall = var.virtual_machines["m3"].network_firewall
  }

  depends_on = [proxmox_vm_qemu.vm2]
}

resource "proxmox_vm_qemu" "vm4" {
  name             = var.virtual_machines["m4"].name
  onboot           = var.virtual_machines["m4"].onboot
  scsihw           = var.virtual_machines["m4"].scsihw
  qemu_os          = var.virtual_machines["m4"].qemu_os
  desc             = var.virtual_machines["m4"].description
  target_node      = var.virtual_machines["m4"].target_node
  os_type          = var.virtual_machines["m4"].os_type
  full_clone       = var.virtual_machines["m4"].full_clone
  clone            = var.virtual_machines["m4"].template
  vmid             = var.virtual_machines["m4"].vmid
  memory           = var.virtual_machines["m4"].memory
  sockets          = var.virtual_machines["m4"].socket
  cores            = var.virtual_machines["m4"].cores
  vcpus            = var.virtual_machines["m4"].vcpus
  cpu              = var.virtual_machines["m4"].cpu
  balloon          = var.virtual_machines["m4"].balloon
  numa             = var.virtual_machines["m4"].numa
  ssh_user         = var.virtual_machines["m4"].ssh_user
  sshkeys          = file(var.ssh_keys["pub"])
  ciuser           = var.virtual_machines["m4"].ssh_user
  cipassword       = var.virtual_machines["m4"].cloud_init_pass
  ipconfig0        = "ip=${var.virtual_machines["m4"].ip_address}/24,gw=${var.virtual_machines["m4"].gateway}"
  automatic_reboot = var.virtual_machines["m4"].automatic_reboot
  hotplug          = var.virtual_machines["m4"].hotplug
  searchdomain     = var.virtual_machines["m4"].searchdomain
  nameserver       = var.virtual_machines["m4"].nameserver
  agent            = var.virtual_machines["m4"].agent

  disk {
    type    = var.disk_type_ci
    storage = var.storage_ci
    slot    = var.slot_ci
  }

  disk {
    storage = var.virtual_machines["m4"].storage_dev
    type    = var.virtual_machines["m4"].disk_type
    size    = var.virtual_machines["m4"].storage
    slot    = var.virtual_machines["m4"].bootdisk
  }

  network {
    bridge   = var.virtual_machines["m4"].network_bridge_type
    model    = var.virtual_machines["m4"].network_model
    mtu      = 0
    macaddr  = var.virtual_machines["m4"].mac_address
    queues   = 0
    rate     = 0
    firewall = var.virtual_machines["m4"].network_firewall
  }

  depends_on = [proxmox_vm_qemu.vm3]
}

resource "proxmox_vm_qemu" "vm5" {
  name             = var.virtual_machines["m5"].name
  onboot           = var.virtual_machines["m5"].onboot
  scsihw           = var.virtual_machines["m5"].scsihw
  qemu_os          = var.virtual_machines["m5"].qemu_os
  desc             = var.virtual_machines["m5"].description
  target_node      = var.virtual_machines["m5"].target_node
  os_type          = var.virtual_machines["m5"].os_type
  full_clone       = var.virtual_machines["m5"].full_clone
  clone            = var.virtual_machines["m5"].template
  vmid             = var.virtual_machines["m5"].vmid
  memory           = var.virtual_machines["m5"].memory
  sockets          = var.virtual_machines["m5"].socket
  cores            = var.virtual_machines["m5"].cores
  vcpus            = var.virtual_machines["m5"].vcpus
  cpu              = var.virtual_machines["m5"].cpu
  balloon          = var.virtual_machines["m5"].balloon
  numa             = var.virtual_machines["m5"].numa
  ssh_user         = var.virtual_machines["m5"].ssh_user
  sshkeys          = file(var.ssh_keys["pub"])
  ciuser           = var.virtual_machines["m5"].ssh_user
  cipassword       = var.virtual_machines["m5"].cloud_init_pass
  ipconfig0        = "ip=${var.virtual_machines["m5"].ip_address}/24,gw=${var.virtual_machines["m5"].gateway}"
  automatic_reboot = var.virtual_machines["m5"].automatic_reboot
  hotplug          = var.virtual_machines["m5"].hotplug
  searchdomain     = var.virtual_machines["m5"].searchdomain
  nameserver       = var.virtual_machines["m5"].nameserver
  agent            = var.virtual_machines["m5"].agent

  disk {
    type    = var.disk_type_ci
    storage = var.storage_ci
    slot    = var.slot_ci
  }

  disk {
    storage = var.virtual_machines["m5"].storage_dev
    type    = var.virtual_machines["m5"].disk_type
    size    = var.virtual_machines["m5"].storage
    slot    = var.virtual_machines["m5"].bootdisk
  }

  network {
    bridge   = var.virtual_machines["m5"].network_bridge_type
    model    = var.virtual_machines["m5"].network_model
    mtu      = 0
    macaddr  = var.virtual_machines["m5"].mac_address
    queues   = 0
    rate     = 0
    firewall = var.virtual_machines["m5"].network_firewall
  }

  depends_on = [proxmox_vm_qemu.vm4]
}

resource "proxmox_vm_qemu" "vm6" {
  name             = var.virtual_machines["m6"].name
  onboot           = var.virtual_machines["m6"].onboot
  scsihw           = var.virtual_machines["m6"].scsihw
  qemu_os          = var.virtual_machines["m6"].qemu_os
  desc             = var.virtual_machines["m6"].description
  target_node      = var.virtual_machines["m6"].target_node
  os_type          = var.virtual_machines["m6"].os_type
  full_clone       = var.virtual_machines["m6"].full_clone
  clone            = var.virtual_machines["m6"].template
  vmid             = var.virtual_machines["m6"].vmid
  memory           = var.virtual_machines["m6"].memory
  sockets          = var.virtual_machines["m6"].socket
  cores            = var.virtual_machines["m6"].cores
  vcpus            = var.virtual_machines["m6"].vcpus
  cpu              = var.virtual_machines["m6"].cpu
  balloon          = var.virtual_machines["m6"].balloon
  numa             = var.virtual_machines["m6"].numa
  ssh_user         = var.virtual_machines["m6"].ssh_user
  sshkeys          = file(var.ssh_keys["pub"])
  ciuser           = var.virtual_machines["m6"].ssh_user
  cipassword       = var.virtual_machines["m6"].cloud_init_pass
  ipconfig0        = "ip=${var.virtual_machines["m6"].ip_address}/24,gw=${var.virtual_machines["m6"].gateway}"
  automatic_reboot = var.virtual_machines["m6"].automatic_reboot
  hotplug          = var.virtual_machines["m6"].hotplug
  searchdomain     = var.virtual_machines["m6"].searchdomain
  nameserver       = var.virtual_machines["m6"].nameserver
  agent            = var.virtual_machines["m6"].agent

  disk {
    type    = var.disk_type_ci
    storage = var.storage_ci
    slot    = var.slot_ci
  }

  disk {
    storage = var.virtual_machines["m6"].storage_dev
    type    = var.virtual_machines["m6"].disk_type
    size    = var.virtual_machines["m6"].storage
    slot    = var.virtual_machines["m6"].bootdisk
  }

  network {
    bridge   = var.virtual_machines["m6"].network_bridge_type
    model    = var.virtual_machines["m6"].network_model
    mtu      = 0
    macaddr  = var.virtual_machines["m6"].mac_address
    queues   = 0
    rate     = 0
    firewall = var.virtual_machines["m6"].network_firewall
  }

  depends_on = [proxmox_vm_qemu.vm5]
}

resource "proxmox_vm_qemu" "vm7" {
  name             = var.virtual_machines["m7"].name
  onboot           = var.virtual_machines["m7"].onboot
  scsihw           = var.virtual_machines["m7"].scsihw
  qemu_os          = var.virtual_machines["m7"].qemu_os
  desc             = var.virtual_machines["m7"].description
  target_node      = var.virtual_machines["m7"].target_node
  os_type          = var.virtual_machines["m7"].os_type
  full_clone       = var.virtual_machines["m7"].full_clone
  clone            = var.virtual_machines["m7"].template
  vmid             = var.virtual_machines["m7"].vmid
  memory           = var.virtual_machines["m7"].memory
  sockets          = var.virtual_machines["m7"].socket
  cores            = var.virtual_machines["m7"].cores
  vcpus            = var.virtual_machines["m7"].vcpus
  cpu              = var.virtual_machines["m7"].cpu
  balloon          = var.virtual_machines["m7"].balloon
  numa             = var.virtual_machines["m7"].numa
  ssh_user         = var.virtual_machines["m7"].ssh_user
  sshkeys          = file(var.ssh_keys["pub"])
  ciuser           = var.virtual_machines["m7"].ssh_user
  cipassword       = var.virtual_machines["m7"].cloud_init_pass
  ipconfig0        = "ip=${var.virtual_machines["m7"].ip_address}/24,gw=${var.virtual_machines["m7"].gateway}"
  automatic_reboot = var.virtual_machines["m7"].automatic_reboot
  hotplug          = var.virtual_machines["m7"].hotplug
  searchdomain     = var.virtual_machines["m7"].searchdomain
  nameserver       = var.virtual_machines["m7"].nameserver
  agent            = var.virtual_machines["m7"].agent

  disk {
    type    = var.disk_type_ci
    storage = var.storage_ci
    slot    = var.slot_ci
  }

  disk {
    storage = var.virtual_machines["m7"].storage_dev
    type    = var.virtual_machines["m7"].disk_type
    size    = var.virtual_machines["m7"].storage
    slot    = var.virtual_machines["m7"].bootdisk
  }

  network {
    bridge   = var.virtual_machines["m7"].network_bridge_type
    model    = var.virtual_machines["m7"].network_model
    mtu      = 0
    macaddr  = var.virtual_machines["m7"].mac_address
    queues   = 0
    rate     = 0
    firewall = var.virtual_machines["m7"].network_firewall
  }

  depends_on = [proxmox_vm_qemu.vm6]
}

resource "proxmox_vm_qemu" "vm8" {
  name             = var.virtual_machines["m8"].name
  onboot           = var.virtual_machines["m8"].onboot
  scsihw           = var.virtual_machines["m8"].scsihw
  qemu_os          = var.virtual_machines["m8"].qemu_os
  desc             = var.virtual_machines["m8"].description
  target_node      = var.virtual_machines["m8"].target_node
  os_type          = var.virtual_machines["m8"].os_type
  full_clone       = var.virtual_machines["m8"].full_clone
  clone            = var.virtual_machines["m8"].template
  vmid             = var.virtual_machines["m8"].vmid
  memory           = var.virtual_machines["m8"].memory
  sockets          = var.virtual_machines["m8"].socket
  cores            = var.virtual_machines["m8"].cores
  vcpus            = var.virtual_machines["m8"].vcpus
  cpu              = var.virtual_machines["m8"].cpu
  balloon          = var.virtual_machines["m8"].balloon
  numa             = var.virtual_machines["m8"].numa
  ssh_user         = var.virtual_machines["m8"].ssh_user
  sshkeys          = file(var.ssh_keys["pub"])
  ciuser           = var.virtual_machines["m8"].ssh_user
  cipassword       = var.virtual_machines["m8"].cloud_init_pass
  ipconfig0        = "ip=${var.virtual_machines["m8"].ip_address}/24,gw=${var.virtual_machines["m8"].gateway}"
  automatic_reboot = var.virtual_machines["m8"].automatic_reboot
  hotplug          = var.virtual_machines["m8"].hotplug
  searchdomain     = var.virtual_machines["m8"].searchdomain
  nameserver       = var.virtual_machines["m8"].nameserver
  agent            = var.virtual_machines["m8"].agent

  disk {
    type    = var.disk_type_ci
    storage = var.storage_ci
    slot    = var.slot_ci
  }

  disk {
    storage = var.virtual_machines["m8"].storage_dev
    type    = var.virtual_machines["m8"].disk_type
    size    = var.virtual_machines["m8"].storage
    slot    = var.virtual_machines["m8"].bootdisk
  }

  network {
    bridge   = var.virtual_machines["m8"].network_bridge_type
    model    = var.virtual_machines["m8"].network_model
    mtu      = 0
    macaddr  = var.virtual_machines["m8"].mac_address
    queues   = 0
    rate     = 0
    firewall = var.virtual_machines["m8"].network_firewall
  }

  depends_on = [proxmox_vm_qemu.vm7]
}

/*
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
    type     = "ssh"
    host     = each.value.ip_address
    user     = each.value.ssh_user
    password = each.value.cloud_init_pass # Substitua pelo valor correspondente da senha
    timeout  = "5m"
  }

  # Provisionamento inicial com Ansible para cada VM
  provisioner "local-exec" {
    working_dir = "../ansible/"
    command     = "ansible-playbook -u ${each.value.ssh_user} -i hosts.yaml provision.yaml --extra-vars 'ansible_password=${each.value.cloud_init_pass}'"
  }

  # Provisionamento para DNS-NS1
  provisioner "local-exec" {
    working_dir = "../ansible/"
    command     = "ansible-playbook -u ${each.value.ssh_user} -i indnsns1.yaml dnsns1.yaml --extra-vars 'ansible_password=${each.value.cloud_init_pass}'"
  }

  # Provisionamento para DNS-NS2
  provisioner "local-exec" {
    working_dir = "../ansible/"
    command     = "ansible-playbook -u ${each.value.ssh_user} -i indnsns2.yaml dnsns2.yaml --extra-vars 'ansible_password=${each.value.cloud_init_pass}'"
  }

  # Provisionamento para AGENTES
  provisioner "local-exec" {
    working_dir = "../ansible/"
    command     = "ansible-playbook -u ${each.value.ssh_user} -i agentes.yaml pb_agentes.yaml --extra-vars 'ansible_password=${each.value.cloud_init_pass}'"
  }

  # Provisionamento para RANCHER
  provisioner "local-exec" {
    working_dir = "../ansible/"
    command     = "ansible-playbook -u ${each.value.ssh_user} -i rancher.yaml pb_rancher.yaml --extra-vars 'ansible_password=${each.value.cloud_init_pass}'"
  }
}
*/

/*
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
    type     = "ssh"
    host     = each.value.ip_address
    user     = each.value.ssh_user
    password = each.value.cloud_init_pass # Substitua pelo valor correspondente da senha
    timeout  = "5m"
  }

  # Provisionamento inicial com Ansible para cada VM
  provisioner "local-exec" {
    working_dir = "../ansible/"
    command     = "ansible-playbook -u ${each.value.ssh_user} -i hosts.yaml provision.yaml --extra-vars 'ansible_password=${each.value.cloud_init_pass}'"
  }

  # Provisionamento para DNS-NS1
  provisioner "local-exec" {
    working_dir = "../ansible/"
    command     = "ansible-playbook -u ${each.value.ssh_user} -i indnsns1.yaml dnsns1.yaml --extra-vars 'ansible_password=${each.value.cloud_init_pass}'"
  }

  # Provisionamento para DNS-NS2
  provisioner "local-exec" {
    working_dir = "../ansible/"
    command     = "ansible-playbook -u ${each.value.ssh_user} -i indnsns2.yaml dnsns2.yaml --extra-vars 'ansible_password=${each.value.cloud_init_pass}'"
  }

  # Provisionamento para AGENTES
  provisioner "local-exec" {
    working_dir = "../ansible/"
    command     = "ansible-playbook -u ${each.value.ssh_user} -i agentes.yaml pb_agentes.yaml --extra-vars 'ansible_password=${each.value.cloud_init_pass}'"
  }

  # Provisionamento para RANCHER
  provisioner "local-exec" {
    working_dir = "../ansible/"
    command     = "ansible-playbook -u ${each.value.ssh_user} -i rancher.yaml pb_rancher.yaml --extra-vars 'ansible_password=${each.value.cloud_init_pass}'"
  }
}
*/