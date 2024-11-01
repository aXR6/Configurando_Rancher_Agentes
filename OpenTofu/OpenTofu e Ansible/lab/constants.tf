locals {
  # Map de máquinas virtuais utilizando valores padrão de variáveis para configurações comuns
  machine_map = {
    machines = {
      /*
      m1 = {
        name                = "ks8-rancher"
        target_node         = "t1102"
        qemu_os             = "Linux"
        template            = "Debian11CloudInitRancher"
        vmid                = 100
        vcpus               = 4
        cores               = 2
        socket              = 2
        memory              = 4096
        balloon             = 4096
        storage             = "35G"
        ip_address          = "192.168.3.10"
        description         = "Máquina virtual - ks8-rancher."
        mac_address         = "FA:58:B8:CE:04:B8"
        cloud_init_pass     = var.cloud_init_password

        # Valores herdados das variáveis padrão
        searchdomain        = var.default_searchdomain
        nameserver          = var.default_nameservers
        network_bridge_type = var.default_network_bridge
        network_model       = var.default_network_model
        cpu                 = var.default_cpu_type
        agent               = var.default_agent_enabled
        hotplug             = var.default_hotplug_options
        ssh_user            = var.default_ssh_user
        storage_dev         = var.default_storage_dev
        gateway             = var.default_gateway
        automatic_reboot    = var.default_reboot
        onboot              = var.default_onboot
        network_firewall    = var.default_network_firewall
        
        disk_type           = var.default_disk_type
        os_type             = var.default_os_type
        numa                = var.default_numa
        full_clone          = var.full_clone
      }
      */

      m2 = {
        name                = "agente-vm1"
        target_node         = "t1102"
        qemu_os             = "Linux"
        template            = "Debian12CloudInitAgente"
        vmid                = 101
        vcpus               = 2
        cores               = 2
        socket              = 1
        memory              = 3072
        balloon             = 3072
        storage             = "35G"
        ip_address          = "192.168.3.11"
        description         = "Máquina virtual - agente-vm1 - para Rancher."
        mac_address         = "22:E2:A0:2F:92:53"
        cloud_init_pass     = var.cloud_init_password

        # Valores herdados das variáveis padrão
        searchdomain        = var.default_searchdomain
        nameserver          = var.default_nameservers
        network_bridge_type = var.default_network_bridge
        network_model       = var.default_network_model
        cpu                 = var.default_cpu_type
        agent               = var.default_agent_enabled
        hotplug             = var.default_hotplug_options
        ssh_user            = var.default_ssh_user
        storage_dev         = var.default_storage_dev
        gateway             = var.default_gateway
        automatic_reboot    = var.default_reboot
        onboot              = var.default_onboot
        network_firewall    = var.default_network_firewall
        disk_type           = var.default_disk_type
        os_type             = var.default_os_type
        numa                = var.default_numa
        full_clone          = var.full_clone
      }

      m3 = {
        name                = "agente-vm2"
        target_node         = "t1102"
        qemu_os             = "Linux"
        template            = "Debian12CloudInitAgente"
        vmid                = 102
        vcpus               = 2
        cores               = 2
        socket              = 1
        memory              = 3072
        balloon             = 3072
        storage             = "35G"
        ip_address          = "192.168.3.12"
        description         = "Máquina virtual - agente-vm2 - para Rancher."
        mac_address         = "82:57:68:61:12:DD"
        cloud_init_pass     = var.cloud_init_password

        # Valores herdados das variáveis padrão
        searchdomain        = var.default_searchdomain
        nameserver          = var.default_nameservers
        network_bridge_type = var.default_network_bridge
        network_model       = var.default_network_model
        cpu                 = var.default_cpu_type
        agent               = var.default_agent_enabled
        hotplug             = var.default_hotplug_options
        ssh_user            = var.default_ssh_user
        storage_dev         = var.default_storage_dev
        gateway             = var.default_gateway
        automatic_reboot    = var.default_reboot
        onboot              = var.default_onboot
        network_firewall    = var.default_network_firewall
        disk_type           = var.default_disk_type
        os_type             = var.default_os_type
        numa                = var.default_numa
        full_clone          = var.full_clone
      }

      /*
      m4 = {
        name                = "agente-vm3"
        target_node         = "t1102"
        qemu_os             = "Linux"
        template            = "Debian12CloudInitAgente"
        vmid                = 103
        vcpus               = 2
        cores               = 2
        socket              = 1
        memory              = 3072
        balloon             = 3072
        storage             = "35G"
        ip_address          = "192.168.3.13"
        description         = "Máquina virtual - agente-vm3 - para Rancher."
        mac_address         = "4E:C0:9E:89:A1:DD"
        cloud_init_pass     = var.cloud_init_password

        # Valores herdados das variáveis padrão
        searchdomain        = var.default_searchdomain
        nameserver          = var.default_nameservers
        network_bridge_type = var.default_network_bridge
        network_model       = var.default_network_model
        cpu                 = var.default_cpu_type
        agent               = var.default_agent_enabled
        hotplug             = var.default_hotplug_options
        ssh_user            = var.default_ssh_user
        storage_dev         = var.default_storage_dev
        gateway             = var.default_gateway
        automatic_reboot    = var.default_reboot
        onboot              = var.default_onboot
        network_firewall    = var.default_network_firewall
        disk_type           = var.default_disk_type
        os_type             = var.default_os_type
        numa                = var.default_numa
        full_clone          = var.full_clone
      }
      */

      m5 = {
        name                = "ns1"
        target_node         = "t1102"
        qemu_os             = "Linux"
        template            = "Debian12CloudInitComum"
        vmid                = 200
        vcpus               = 1
        cores               = 1
        socket              = 1
        memory              = 1024
        balloon             = 512
        storage             = "10G"
        ip_address          = "192.168.3.200"
        description         = "Máquina virtual - DNS Master."
        mac_address         = "6E:60:3D:9C:6E:60"
        cloud_init_pass     = var.cloud_init_password

        # Valores herdados das variáveis padrão
        searchdomain        = var.default_searchdomain
        nameserver          = var.default_nameservers
        network_bridge_type = var.default_network_bridge
        network_model       = var.default_network_model
        cpu                 = var.default_cpu_type
        agent               = var.default_agent_enabled
        hotplug             = var.default_hotplug_options
        ssh_user            = var.default_ssh_user
        storage_dev         = var.default_storage_dev
        gateway             = var.default_gateway
        automatic_reboot    = var.default_reboot
        onboot              = var.default_onboot
        network_firewall    = var.default_network_firewall
        disk_type           = var.default_disk_type
        os_type             = var.default_os_type
        numa                = var.default_numa
        full_clone          = var.full_clone
      }

      m6 = {
        name                = "ns2"
        target_node         = "t1102"
        qemu_os             = "Linux"
        template            = "Debian12CloudInitComum"
        vmid                = 201
        vcpus               = 1
        cores               = 1
        socket              = 1
        memory              = 1024
        balloon             = 512
        storage             = "10G"
        ip_address          = "192.168.3.201"
        description         = "Máquina virtual - DNS Slave."
        mac_address         = "02:C0:10:09:A7:D0"
        cloud_init_pass     = var.cloud_init_password

        # Valores herdados das variáveis padrão
        searchdomain        = var.default_searchdomain
        nameserver          = var.default_nameservers
        network_bridge_type = var.default_network_bridge
        network_model       = var.default_network_model
        cpu                 = var.default_cpu_type
        agent               = var.default_agent_enabled
        hotplug             = var.default_hotplug_options
        ssh_user            = var.default_ssh_user
        storage_dev         = var.default_storage_dev
        gateway             = var.default_gateway
        automatic_reboot    = var.default_reboot
        onboot              = var.default_onboot
        network_firewall    = var.default_network_firewall
        disk_type           = var.default_disk_type
        os_type             = var.default_os_type
        numa                = var.default_numa
        full_clone          = var.full_clone
      }

      /*
      m7 = {
        name                = "nfstorrent"
        target_node         = "t1102"
        qemu_os             = "Linux"
        template            = "Debian12CloudInitComum"
        vmid                = 203
        vcpus               = 1
        cores               = 1
        socket              = 2
        memory              = 1024
        balloon             = 512
        storage             = "120G"
        ip_address          = "192.168.3.203"
        description         = "Máquina virtual - NFS TORRENT."
        mac_address         = "1E:45:79:99:5C:7B"
        cloud_init_pass     = var.cloud_init_password

        # Valores herdados das variáveis padrão
        searchdomain        = var.default_searchdomain
        nameserver          = var.default_nameservers
        network_bridge_type = var.default_network_bridge
        network_model       = var.default_network_model
        cpu                 = var.default_cpu_type
        agent               = var.default_agent_enabled
        hotplug             = var.default_hotplug_options
        ssh_user            = var.default_ssh_user
        storage_dev         = var.default_storage_dev
        gateway             = var.default_gateway
        automatic_reboot    = var.default_reboot
        onboot              = var.default_onboot
        network_firewall    = var.default_network_firewall
        disk_type           = var.default_disk_type
        os_type             = var.default_os_type
        numa                = var.default_numa
        full_clone          = var.full_clone
      }
      */
    }
  }

  machines = lookup(local.machine_map, "machines", {})
}