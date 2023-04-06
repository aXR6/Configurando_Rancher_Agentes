locals {
  machine_map = {
    machines = {
      m1 = {
        name                = "ks8-vm1"
        target_node         = "pvedell5437" # Name of the Proxmox Server
        qemu_os             = "Linux"       # Type of Operating System
        os_type             = "cloud-init"  # Set to cloud-init to utilize templates
        agent               = 1             # Set to 1 to enable the QEMU Guest Agent. Note, you must run the qemu-guest-agent daemon in the guest for this to have any effect.
        full_clone          = true          # Set to true to create a full clone, or false to create a linked clone. See the docs about cloning for more info. Only applies when clone is set.
        template            = "Debian11CloudInit"      # Name of Template Used to Clone
        cores               = 2
        socket              = 1
        memory              = 3500
        storage             = "35G"         # Size of Secondary hard drive assiged as bootable
        ip_address          = "192.168.2.11"
        gateway             = "192.168.2.254"
        description         = "Máquina virtual - ks8-vm1 - para Rancher."
        ssh_user            = "ks8vm1"
        mac_address         = "22:E2:A0:2F:92:53"
        disk_type           = "virtio"
        storage_dev         = "local-lvm"
        network_bridge_type = "vmbr0"
        network_model       = "virtio"
        cloud_init_pass     = "ks8vm1"
        automatic_reboot    = true
        network_firewall    = false #defaults to false
        dns_servers         = "192.168.2.200 192.168.2.201 8.8.8.8"
      }

      m2 = {
        name                = "ks8-vm2"
        target_node         = "pvedellt110" # Name of the Proxmox Server
        qemu_os             = "Linux"       # Type of Operating System
        os_type             = "cloud-init"  # Set to cloud-init to utilize templates
        agent               = 1             # Set to 1 to enable the QEMU Guest Agent. Note, you must run the qemu-guest-agent daemon in the guest for this to have any effect.
        full_clone          = true          # Set to true to create a full clone, or false to create a linked clone. See the docs about cloning for more info. Only applies when clone is set.
        template            = "Debian11CloudInit"      # Name of Template Used to Clone
        cores               = 2
        socket              = 1
        memory              = 3500
        storage             = "35G"         # Size of Secondary hard drive assiged as bootable
        ip_address          = "192.168.2.12"
        gateway             = "192.168.2.254"
        description         = "Máquina virtual - ks8-vm2 - para Rancher."
        ssh_user            = "ks8vm2"
        mac_address         = "22:E2:A0:2F:92:53"
        disk_type           = "virtio"
        storage_dev         = "local-lvm"
        network_bridge_type = "vmbr0"
        network_model       = "virtio"
        cloud_init_pass     = "ks8vm2"
        automatic_reboot    = true
        network_firewall    = false #defaults to false
        dns_servers         = "192.168.2.200 192.168.2.201 8.8.8.8"
      }

      m3 = {
        name                = "ks8-vm3"
        target_node         = "pvedellt110" # Name of the Proxmox Server
        qemu_os             = "Linux"       # Type of Operating System
        os_type             = "cloud-init"  # Set to cloud-init to utilize templates
        agent               = 1             # Set to 1 to enable the QEMU Guest Agent. Note, you must run the qemu-guest-agent daemon in the guest for this to have any effect.
        full_clone          = true          # Set to true to create a full clone, or false to create a linked clone. See the docs about cloning for more info. Only applies when clone is set.
        template            = "Debian11CloudInit"      # Name of Template Used to Clone
        cores               = 2
        socket              = 1
        memory              = 3500
        storage             = "35G"         # Size of Secondary hard drive assiged as bootable
        ip_address          = "192.168.2.13"
        gateway             = "192.168.2.254"
        description         = "Máquina virtual - ks8-vm3 - para Rancher."
        ssh_user            = "ks8vm3"
        mac_address         = "22:E2:A0:2F:92:53"
        disk_type           = "virtio"
        storage_dev         = "local-lvm"
        network_bridge_type = "vmbr0"
        network_model       = "virtio"
        cloud_init_pass     = "ks8vm3"
        automatic_reboot    = true
        network_firewall    = false #defaults to false
        dns_servers         = "192.168.2.200 192.168.2.201 8.8.8.8"
      }
    }
  }

  machines = lookup(local.machine_map, "machines", {})
}