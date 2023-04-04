# Provider Proxmox
terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      #version = "2.9.14"
    }
  }
}

# Definição do provider Proxmox
provider "proxmox" {
  pm_api_url = "https://proxmox-ks8.ddns.net:8006/api2/json"
  pm_user = "root"
  pm_password = "902grego1989"
  pm_tls_insecure = false
  #pm_otp       = "<PROXMOX_OTP>" # caso seja necessário
}

# Definição das variáveis
variable "proxmox_node" {
  type = string
  description = "Nome do node Proxmox"
}

variable "vm_name" {
  type = string
  description = "Nome da máquina virtual"
}

variable "vm_description" {
  type = string
  description = "Descrição da máquina virtual"
}

variable "vm_disk_size" {
  type = number
  description = "Tamanho do disco em GB"
  default = 40
}

variable "vm_memory" {
  type = number
  description = "Quantidade de memória RAM em GB"
  default = 3.5
}

variable "vm_swap" {
  type = number
  description = "Tamanho da partição de swap em GB"
  default = 2
}

variable "vm_os" {
  type = string
  description = "Sistema operacional da máquina virtual"
  default = "debian-11.0-standard_11.0-3_amd64"
}

# Criação da máquina virtual
resource "proxmox_vm_qemu" "example" {
  name        = var.vm_name
  description = var.vm_description
  target_node = var.proxmox_node
  memory      = var.vm_memory * 1024 # Converter para MB
  os_type     = "cloud-init"
  os_variant  = "debian11"
  agent       = 1
  
  # Configuração do disco
  disk {
    size = var.vm_disk_size
  }

  # Configuração da partição swap
  # É necessário criar um segundo disco para a partição swap
  disk {
    size = var.vm_swap
    ssd  = false # definido como disco convencional
    id   = "virtio1" # id do segundo disco
  }
  
  # Configuração da rede
  network {
    model = "virtio"
  }

  # Configuração do sistema operacional via cloud-init
  cloudinit {
    hostname = var.vm_name
    user_data = <<-EOF
      #cloud-config
      ssh_authorized_keys:
        - AAAAC3NzaC1lZDI1NTE5AAAAIFEPcbp2MGpv+1qWqhoOKAceCNEYmUSo1Wiup++y8/sQ
      package_upgrade: true
      packages:
        - nano
    EOF
  }

  # Configuração do ISO de instalação do sistema operacional
  # O ISO do Debian 11 precisa ser carregado no armazenamento local do Proxmox
  # e pode ser referenciado pelo nome "debian-11.0.0-amd64-netinst.iso"
  # aqui estamos usando um armazenamento NFS compartilhado com o Proxmox
  cdrom {
    pool = "proxmox"
    volume = "isos/firmware-11.6.0-amd64-netinst.iso"
    #server = "<SEU_SERVIDOR_NFS>"
    #export = "<SEU_EXPORT_NFS>"
    #path = "/mnt/nfs"
  }
}
