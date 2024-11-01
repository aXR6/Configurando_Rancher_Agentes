# Variáveis padrão para máquinas virtuais
variable "default_searchdomain" {
  description = "Domínio de busca padrão para todas as máquinas virtuais"
  type        = string
  default     = "pve.datacenter.tsc"
}

variable "default_nameservers" {
  description = "Servidores DNS padrão para todas as máquinas virtuais"
  type        = string
  default     = "192.168.2.200 192.168.2.201 192.168.2.254 8.8.8.8"
}

variable "default_network_bridge" {
  description = "Tipo de ponte de rede padrão para todas as máquinas virtuais"
  type        = string
  default     = "vmbr0"
}

variable "default_network_model" {
  description = "Modelo de rede padrão para todas as máquinas virtuais"
  type        = string
  default     = "virtio"
}

variable "default_cpu_type" {
  description = "Tipo de CPU padrão para todas as máquinas virtuais"
  type        = string
  default     = "kvm64"
}

variable "default_hotplug_options" {
  description = "Recursos de hotplug padrão para todas as máquinas virtuais"
  type        = string
  default     = "network,disk,cpu,memory"
}

variable "default_ssh_user" {
  description = "Usuário SSH padrão para todas as máquinas virtuais"
  type        = string
  default     = "notroot"
}

variable "default_agent_enabled" {
  description = "Habilitar o QEMU Guest Agent (1 = habilitado)"
  type        = number
  default     = 1
}

variable "default_storage_dev" {
  description = "Dispositivo de armazenamento padrão"
  type        = string
  default     = "local-lvm"
}

variable "default_gateway" {
  description = "Gateway padrão para todas as máquinas virtuais"
  type        = string
  default     = "192.168.2.254"
}

variable "default_reboot" {
  description = "Habilitar reinicialização automática"
  type        = bool
  default     = true
}

variable "default_onboot" {
  description = "Habilitar inicialização automática (onboot)"
  type        = bool
  default     = true
}

variable "default_network_firewall" {
  description = "Configuração padrão de firewall de rede"
  type        = bool
  default     = false
}

# Senhas sensíveis para inicialização do cloud-init
variable "cloud_init_password" {
  description = "Senha padrão para cloud-init (usar somente se necessário)"
  type        = string
  sensitive   = true
  default     = "testando123"
}

# Tipo de disco padrão para todas as máquinas virtuais
variable "default_disk_type" {
  description = "Tipo de disco padrão para todas as máquinas virtuais"
  type        = string
  default     = "scsi"
}

# Tipo de sistema operacional padrão para as máquinas virtuais
variable "default_os_type" {
  description = "Tipo de sistema operacional utilizado nas máquinas virtuais (por exemplo, cloud-init)"
  type        = string
  default     = "cloud-init"
}

# Habilitar NUMA (Non-Uniform Memory Access) para melhor desempenho em VM
variable "default_numa" {
  description = "Habilitar NUMA para máquinas virtuais"
  type        = bool
  default     = true
}

# Definir se a clonagem será completa ou vinculada
variable "full_clone" {
  description = "Definir como true para criar um clone completo ou false para criar um clone vinculado."
  type        = bool
  default     = true
}