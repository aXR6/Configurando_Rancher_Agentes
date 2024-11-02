# Variáveis padrão para máquinas virtuais
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

variable "vm_network_bridge" {
  description = "Tipo de ponte de rede padrão para todas as máquinas virtuais"
  type        = string
  default     = "vmbr0"
}

variable "vm_network_model" {
  description = "Modelo de rede padrão para todas as máquinas virtuais"
  type        = string
  default     = "virtio"
}

variable "vm_cpu_type" {
  description = "Tipo de CPU padrão para todas as máquinas virtuais"
  type        = string
  default     = "kvm64"
}

variable "vm_hotplug_options" {
  description = "Recursos de hotplug padrão para todas as máquinas virtuais"
  type        = string
  default     = "network,disk,cpu,memory"
}

variable "vm_ssh_user" {
  description = "Usuário SSH padrão para todas as máquinas virtuais"
  type        = string
  default     = "notroot"
}

variable "vm_agent_enabled" {
  description = "Habilitar o QEMU Guest Agent (1 = habilitado)"
  type        = number
  default     = 1
}

variable "vm_storage_dev" {
  description = "Dispositivo de armazenamento padrão"
  type        = string
  default     = "DadosExtra"
}

variable "vm_gateway" {
  description = "Gateway padrão para todas as máquinas virtuais"
  type        = string
  default     = "192.168.3.1"
}

variable "vm_reboot" {
  description = "Habilitar reinicialização automática"
  type        = bool
  default     = true
}

variable "vm_onboot" {
  description = "Habilitar inicialização automática (onboot)"
  type        = bool
  default     = true
}

variable "vm_network_firewall" {
  description = "Configuração padrão de firewall de rede"
  type        = bool
  default     = false
}

# Senhas sensíveis para inicialização do cloud-init
variable "vm_cloud_init_password" {
  description = "Senha padrão para cloud-init (usar somente se necessário)"
  type        = string
  sensitive   = true
  default     = "testando123"
}

# Tipo de disco padrão para todas as máquinas virtuais
variable "vm_disk_type" {
  description = "Tipo de disco padrão para todas as máquinas virtuais"
  type        = string
  default     = "disk"
}

# Tipo de sistema operacional padrão para as máquinas virtuais
variable "vm_os_type" {
  description = "Tipo de sistema operacional utilizado nas máquinas virtuais (por exemplo, cloud-init)"
  type        = string
  default     = "cloud-init"
}

# Habilitar NUMA (Non-Uniform Memory Access) para melhor desempenho em VM
variable "vm_numa" {
  description = "Habilitar NUMA para máquinas virtuais"
  type        = bool
  default     = true
}

# Definir se a clonagem será completa ou vinculada
variable "vm_full_clone" {
  description = "Definir como true para criar um clone completo ou false para criar um clone vinculado."
  type        = bool
  default     = true
}

variable "vm_ostype" {
  description = "Define o tipo de sistema operacional para a VM"
  type        = string
  default     = "l26" # padrão para Linux kernel 2.6 ou superior
}

variable "vm_slot" {
  description = "Define o slot de armazenamento para a VM"
  type        = string
  default     = "scsi0" # padrão para o slot scsi0
}