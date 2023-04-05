variable "proxmox_host" {
	type = map
     default = {
       pm_api_url = "https://192.168.2.50:8006/api2/json"
       pm_user = "root"
       target_node = "pvedell5437"
       pm_tls_insecure = true
     }
}

variable "vmid" {
	default     = 400
	description = "Starting ID for the CTs"
}


variable "hostnames" {
  description = "VMs to be created"
  type        = list(string)
  default     = ["prod-vm", "staging-vm", "dev-vm"]
}

variable "rootfs_size" {
	default = "2G"
}

variable "ips" {
    description = "IPs of the VMs, respective to the hostname order"
    type        = list(string)
	default     = ["10.0.42.80", "10.0.42.81", "10.0.42.82"]
}

variable "ssh_keys" {
	type = map
     default = {
       pub  = "~/.ssh/id_rsa.pub"
       priv = "~/.ssh/id_rsa"
     }
}

variable "ssh_password" {}

variable "user" {
	default     = "notroot"
	description = "User used to SSH into the machine and provision it"
}