variable "virtual_machines" {
  type        = map(any)
  default     = {}
  description = "Identifies the object of virtual machines."
}

variable "ssh_keys" {
  default = {
    pub  = "~/.ssh/id_rsa.pub"
    priv = "~/.ssh/id_rsa"
  }
}

# Disco Cloud-Init configurado como disco adicional
variable "disk_type_ci" {
  description = "Define o tipo de disco para Cloud-Init."
  type        = string
  default     = "cloudinit"
}

variable "storage_ci" {
  description = "Define o armazenamento onde o disco será alocado."
  type        = string
  default     = "local-lvm"
}

variable "size_ci" {
  description = "Tamanho do disco Cloud-Init, definido em GB (ex: 4G)."
  type        = string
  default     = "100M"
}

variable "slot_ci" {
  description = "Slot de disco onde o Cloud-Init será montado (ex: ide2)."
  type        = string
  default     = "ide2"
}