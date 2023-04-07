locals {
  machine_map = {
    machines = {
      m1 = {
        name                = "ks8-vm1"
        target_node         = "dell5437" # Nome do Servidor Proxmox
        qemu_os             = "Linux"       # Tipo de sistema operacional
        os_type             = "cloud-init"  # Defina como cloud-init para utilizar modelos
        agent               = 1             # Defina como 1 para habilitar o QEMU Guest Agent. Observe que você deve executar o daemon qemu-guest-agent no convidado para que isso tenha algum efeito.
        full_clone          = true          # Defina como true para criar um clone completo ou false para criar um clone vinculado. Veja os documentos sobre clonagem para mais informações. Só se aplica quando o clone está definido.
        template            = "Debian11CloudInit"      # Nome do modelo usado para clonar
        cores               = 2
        socket              = 1
        memory              = 3500
        storage             = "35G"         # Tamanho do disco rígido secundário atribuído como inicializável
        ip_address          = "192.168.2.11"
        gateway             = "192.168.2.254"
        description         = "Máquina virtual - ks8-vm1 - para Rancher."
        ssh_user            = "ks8vm1"
        mac_address         = "22:E2:A0:2F:92:53"
        disk_type           = "virtio"
        storage_dev         = "local-zfs"
        network_bridge_type = "vmbr0"
        network_model       = "virtio"
        cloud_init_pass     = "ks8vm1"
        automatic_reboot    = true
        network_firewall    = false # o padrão é falso
        dns_servers         = "192.168.2.200 192.168.2.201 8.8.8.8"
      }

      m2 = {
        name                = "ks8-vm2"
        target_node         = "dell5437" # Nome do Servidor Proxmox
        qemu_os             = "Linux"       # Tipo de sistema operacional
        os_type             = "cloud-init"  # Defina como cloud-init para utilizar modelos
        agent               = 1             # Defina como 1 para habilitar o QEMU Guest Agent. Observe que você deve executar o daemon qemu-guest-agent no convidado para que isso tenha algum efeito.
        full_clone          = true          # Defina como true para criar um clone completo ou false para criar um clone vinculado. Veja os documentos sobre clonagem para mais informações. Só se aplica quando o clone está definido.
        template            = "Debian11CloudInit"      # Nome do modelo usado para clonar
        cores               = 2
        socket              = 1
        memory              = 3500
        storage             = "35G"         # Tamanho do disco rígido secundário atribuído como inicializável
        ip_address          = "192.168.2.12"
        gateway             = "192.168.2.254"
        description         = "Máquina virtual - ks8-vm2 - para Rancher."
        ssh_user            = "ks8vm2"
        mac_address         = "82:57:68:61:12:DD"
        disk_type           = "virtio"
        storage_dev         = "local-zfs"
        network_bridge_type = "vmbr0"
        network_model       = "virtio"
        cloud_init_pass     = "ks8vm2"
        automatic_reboot    = true
        network_firewall    = false # o padrão é falso
        dns_servers         = "192.168.2.200 192.168.2.201 8.8.8.8"
      }

      m3 = {
        name                = "ks8-vm3"
        target_node         = "dell5437" # Nome do Servidor Proxmox
        qemu_os             = "Linux"       # Tipo de sistema operacional
        os_type             = "cloud-init"  # Defina como cloud-init para utilizar modelos
        agent               = 1             # Defina como 1 para habilitar o QEMU Guest Agent. Observe que você deve executar o daemon qemu-guest-agent no convidado para que isso tenha algum efeito.
        full_clone          = true          # Defina como true para criar um clone completo ou false para criar um clone vinculado. Veja os documentos sobre clonagem para mais informações. Só se aplica quando o clone está definido.
        template            = "Debian11CloudInit"      # Nome do modelo usado para clonar
        cores               = 2
        socket              = 1
        memory              = 3500
        storage             = "35G"         # Tamanho do disco rígido secundário atribuído como inicializável
        ip_address          = "192.168.2.13"
        gateway             = "192.168.2.254"
        description         = "Máquina virtual - ks8-vm3 - para Rancher."
        ssh_user            = "ks8vm3"
        mac_address         = "4E:C0:9E:89:A1:DD"
        disk_type           = "virtio"
        storage_dev         = "local-zfs"
        network_bridge_type = "vmbr0"
        network_model       = "virtio"
        cloud_init_pass     = "ks8vm3"
        automatic_reboot    = true
        network_firewall    = false # o padrão é falso
        dns_servers         = "192.168.2.200 192.168.2.201 8.8.8.8"
      }

      m4 = {
        name                = "ks8-rancher"
        target_node         = "dell5437" # Nome do Servidor Proxmox
        qemu_os             = "Linux"       # Tipo de sistema operacional
        os_type             = "cloud-init"  # Defina como cloud-init para utilizar modelos
        agent               = 1             # Defina como 1 para habilitar o QEMU Guest Agent. Observe que você deve executar o daemon qemu-guest-agent no convidado para que isso tenha algum efeito.
        full_clone          = true          # Defina como true para criar um clone completo ou false para criar um clone vinculado. Veja os documentos sobre clonagem para mais informações. Só se aplica quando o clone está definido.
        template            = "Debian11CloudInit"      # Nome do modelo usado para clonar
        cores               = 2
        socket              = 1
        memory              = 3500
        storage             = "35G"         # Tamanho do disco rígido secundário atribuído como inicializável
        ip_address          = "192.168.2.10"
        gateway             = "192.168.2.254"
        description         = "Máquina virtual - ks8-rancher."
        ssh_user            = "ks8rancher"
        mac_address         = "FA:58:B8:CE:04:B8"
        disk_type           = "virtio"
        storage_dev         = "local-zfs"
        network_bridge_type = "vmbr0"
        network_model       = "virtio"
        cloud_init_pass     = "ks8rancher"
        automatic_reboot    = true
        network_firewall    = false # o padrão é falso
        dns_servers         = "192.168.2.200 192.168.2.201 8.8.8.8"
      }
    }
  }

  machines = lookup(local.machine_map, "machines", {})
}