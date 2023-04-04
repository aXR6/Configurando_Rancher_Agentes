# Provider Proxmox
terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "1"
    }
  }
}

provider "proxmox" {
  pm_api_url   = "https://proxmox-ks8.ddns.net:8006/api2/json"
  pm_user_name = "root"
  pm_password  = "902grego1989"
  pm_tls_insecure = true
}

# Resource de configuração da máquina virtual
resource "proxmox_vm_qemu" "ks8-vm1" {
  name = "vm-debian-11"
  target_node = "pvedell5437"

  # Configurações de memória RAM e SWAP
  memory = "3584"
  swap   = "2048"

  # Configurações de disco
  disk_size = "40G"
  storage   = "Dell5437"

  # Configurações do sistema operacional
  os_type = "debian"
  os_variant = "debian11"
  
  # Configuração de rede
  network {
    model = "virtio"
  }
}

# Recurso para a rede virtual
resource "proxmox_network" "example" {
  id   = "vmbr0"
  vlan = "0"
}