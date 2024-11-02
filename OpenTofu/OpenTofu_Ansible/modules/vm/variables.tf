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