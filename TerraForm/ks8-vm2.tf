# Provider Proxmox
provider "proxmox" {
  pm_api_url   = "https://seu.servidor.proxmox:8006/api2/json"
  pm_user_name = "seu_usuario"
  pm_password  = "sua_senha"
  pm_tls_insecure = true
}

# Resource de configuração da máquina virtual
resource "proxmox_vm_qemu" "example" {
  name = "vm-debian-11"
  target_node = "seu_servidor_proxmox"

  # Configurações de memória RAM e SWAP
  memory = "3584"
  swap   = "2048"

  # Configurações de disco
  disk_size = "40G"
  storage   = "seu_armazenamento"

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