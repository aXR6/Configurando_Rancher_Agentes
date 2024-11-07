# Variáveis padrão de rede para máquinas virtuais
variable "vm_searchdomain" {
  description = "Domínio de busca padrão para todas as máquinas virtuais"
  type        = string
  default     = "pve.datacenter.tsc"
}

variable "vm_nameservers" {
  description = "Servidores DNS padrão para todas as máquinas virtuais"
  type        = string
  default     = "192.168.3.200 192.168.3.201 192.168.3.1 8.8.8.8"
}

variable "vm_gateway" {
  description = "Gateway padrão para todas as máquinas virtuais"
  type        = string
  default     = "192.168.3.1"
}

variable "vm_network_bridge" {
  description = "Tipo de ponte de rede padrão para todas as máquinas virtuais"
  type        = string
  default     = "vmbr0"
}

variable "vm_network_model" {
  description = "Modelo de rede padrão para todas as máquinas virtuais (ex: virtio para desempenho otimizado)"
  type        = string
  default     = "virtio"
}

variable "vm_network_firewall" {
  description = "Configuração padrão de firewall de rede (true para habilitado, false para desabilitado)"
  type        = bool
  default     = false
}

# Configurações gerais de sistema para máquinas virtuais
variable "vm_onboot" {
  description = "Habilitar inicialização automática (onboot) das VMs"
  type        = bool
  default     = true
}

variable "vm_reboot" {
  description = "Habilitar reinicialização automática em caso de falha"
  type        = bool
  default     = true
}

variable "vm_ssh_user" {
  description = "Usuário SSH padrão para todas as máquinas virtuais"
  type        = string
  default     = "notroot"
}

variable "vm_cloud_init_password" {
  description = "Senha padrão para cloud-init (usar somente se necessário)"
  type        = string
  sensitive   = true
  default     = "123"
}

variable "vm_agent_enabled" {
  description = "Habilitar o QEMU Guest Agent (1 = habilitado, 0 = desabilitado)"
  type        = number
  default     = 1
}

# Configurações de hardware padrão para máquinas virtuais
variable "vm_cpu_type" {
  description = "Tipo de CPU padrão para todas as máquinas virtuais (ex: kvm64 para compatibilidade)"
  type        = string
  default     = "kvm64"
}

variable "vm_numa" {
  description = "Habilitar NUMA (Non-Uniform Memory Access) para melhor desempenho em VMs com várias CPUs"
  type        = bool
  default     = true
}

variable "vm_hotplug_options" {
  description = "Recursos de hotplug padrão para todas as máquinas virtuais (ex: network, disk, cpu, memory)"
  type        = string
  default     = "network,disk,cpu,memory"
}

# Configuração de armazenamento padrão para máquinas virtuais - 01
variable "vm_storage_dev" {
  description = "Dispositivo de armazenamento padrão para as máquinas virtuais"
  type        = string
  default     = "DadosExtra"
}

# Configuração de armazenamento padrão para máquinas virtuais - 02
variable "vm_storage_dev_2" {
  description = "Dispositivo de armazenamento padrão para as máquinas virtuais"
  type        = string
  default     = "local-lvm"
}

variable "vm_disk_type" {
  description = "Tipo de disco padrão para todas as máquinas virtuais (ex: disk para armazenamento)"
  type        = string
  default     = "disk"
}

variable "vm_boot_order" {
  description = "Ordem de boot da VM. Use 'c' para disco, 'd' para CD-ROM, 'n' para rede, etc."
  type        = string
  default     = "c"
}

variable "vm_scsihw_type" {
  description = "Define o tipo de controlador SCSI a ser usado para a VM."
  type        = string
  default     = "virtio-scsi-single"
}

variable "vm_bootdisk" {
  description = "Define o slot de armazenamento padrão para a VM (ex: scsi0)"
  type        = string
  default     = "scsi0"
}

# Configurações de sistema operacional para máquinas virtuais
variable "vm_os_type" {
  description = "Tipo de sistema operacional utilizado nas máquinas virtuais (ex: cloud-init para Linux)"
  type        = string
  default     = "cloud-init"
}

variable "vm_ostype" {
  description = "Define o tipo de sistema operacional específico da VM (ex: l26 para Linux kernel 2.6 ou superior)"
  type        = string
  default     = "l26"
}

# Clonagem e provisionamento
variable "vm_full_clone" {
  description = "Definir como true para criar um clone completo ou false para um clone vinculado"
  type        = bool
  default     = true
}