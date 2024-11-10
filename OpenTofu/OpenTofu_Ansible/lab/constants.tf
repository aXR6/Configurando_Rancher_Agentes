/*
  192.168.3.10;   # Rancher     -   FA:58:B8:CE:04:B8
	192.168.3.11;   # agente-vm1  -   22:E2:A0:2F:92:53
	192.168.3.12;   # agente-vm2  -   82:57:68:61:12:DD
	192.168.3.13;   # agente-vm3  -   74:86:7A:F4:34:EC
	192.168.3.200;  # dns-ns1     -   6E:60:3D:9C:6E:60
	192.168.3.201;  # dns-ns2     -   02:C0:10:09:A7:D0
  192.168.3.100;  # NFS         -   52:54:00:85:F2:BA
*/
locals {
  # Configurações padrão para todas as máquinas virtuais
  default_vm_config = {
    searchdomain        = var.vm_searchdomain
    nameserver          = var.vm_nameservers
    network_bridge_type = var.vm_network_bridge
    network_model       = var.vm_network_model
    cpu                 = var.vm_cpu_type
    agent               = var.vm_agent_enabled
    hotplug             = var.vm_hotplug_options
    ssh_user            = var.vm_ssh_user
    gateway             = var.vm_gateway
    automatic_reboot    = var.vm_reboot
    onboot              = var.vm_onboot
    network_firewall    = var.vm_network_firewall
    disk_type           = var.vm_disk_type
    os_type             = var.vm_os_type
    numa                = var.vm_numa
    full_clone          = var.vm_full_clone
    bootdisk            = var.vm_bootdisk
    qemu_os             = var.vm_ostype
    cloud_init_pass     = var.vm_cloud_init_password
    #boot               = var.vm_boot_order "Ordem de boot da VM. Use 'c' para disco, 'd' para CD-ROM, 'n' para rede, etc."
    scsihw              = var.vm_scsihw_type
  }

  # Definição de máquinas virtuais específicas
  machine_map = {

    m1 = merge(local.default_vm_config, {
      name            = "nfs"
      target_node     = "pve"
      template        = "Debian12CloudInitNFS"
      vmid            = 100
      vcpus           = 1
      cores           = 1
      socket          = 1
      memory          = 1024
      balloon         = 512
      storage         = "900G"
      ip_address      = "192.168.3.100"
      description     = "Máquina virtual - NFS."
      mac_address     = "52:54:00:85:F2:BA"
      storage_dev     = var.vm_storage_dev_3
    })

    m2 = merge(local.default_vm_config, {
      name            = "agente-vm1"
      target_node     = "pve"
      template        = "Debian12CloudInitAgente"
      vmid            = 101
      vcpus           = 2
      cores           = 2
      socket          = 1
      memory          = 3072
      balloon         = 1024
      storage         = "35G"
      ip_address      = "192.168.3.11"
      description     = "Máquina virtual - agente-vm1 - para Rancher."
      mac_address     = "22:E2:A0:2F:92:53"
      storage_dev     = var.vm_storage_dev_2
    })

    m3 = merge(local.default_vm_config, {
      name            = "agente-vm2"
      target_node     = "pve"
      template        = "Debian12CloudInitAgente"
      vmid            = 102
      vcpus           = 2
      cores           = 2
      socket          = 1
      memory          = 3072
      balloon         = 1024
      storage         = "35G"
      ip_address      = "192.168.3.12"
      description     = "Máquina virtual - agente-vm2 - para Rancher."
      mac_address     = "82:57:68:61:12:DD"
      storage_dev     = var.vm_storage_dev_2
    })

    m4 = merge(local.default_vm_config, {
      name            = "ns1"
      target_node     = "pve"
      template        = "Debian12CloudInitDNS1"
      vmid            = 200
      vcpus           = 1
      cores           = 1
      socket          = 1
      memory          = 1024
      balloon         = 512
      storage         = "10G"
      ip_address      = "192.168.3.200"
      description     = "Máquina virtual - DNS Master."
      mac_address     = "6E:60:3D:9C:6E:60"
      storage_dev     = var.vm_storage_dev
    })

    m5 = merge(local.default_vm_config, {
      name            = "ns2"
      target_node     = "pve"
      template        = "Debian12CloudInitDNS2"
      vmid            = 201
      vcpus           = 1
      cores           = 1
      socket          = 1
      memory          = 1024
      balloon         = 512
      storage         = "10G"
      ip_address      = "192.168.3.201"
      description     = "Máquina virtual - DNS Slave."
      mac_address     = "02:C0:10:09:A7:D0"
      storage_dev     = var.vm_storage_dev
    })
  }

  # Map resultante das máquinas
  machines = local.machine_map
}