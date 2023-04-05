variable "proxmox_host" {
	type = map
     default = {
       pm_api_url = "https://192.168.2.50:8006/api2/json"
       pm_user = "root"
       target_node = "pvedell5437"
     }
}

variable "vmid" {
	default     = 300
	description = "Starting ID for the CTs"
}


variable "hostnames" {
  description = "Containers to be created"
  type        = list(string)
  default     = ["prod-ct"]
}


variable "rootfs_size" {
	description = "Root filesystem size in GB"
	default = "2G"
}

variable "ips" {
    description = "IPs of the containers, respective to the hostname order"
    type        = list(string)
	default     = ["192.168.2.55"]
}

variable "user" {
	default     = "root"
	description = "Ansible user used to provision the container"
}

variable "ssh_keys" {
	type = map
     default = {
       pub  = "~/.ssh/id_rsa.pub"
       priv = "~/.ssh/id_rsa"
     }
}