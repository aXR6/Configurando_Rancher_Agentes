terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      #version = "2.9.11"
      version = "3.0.1-rc4"
    }
    tls = {
      source  = "hashicorp/tls"
      #version = "3.3.0"
      version = "4.0.6"
    }
  }
  required_version = ">= 0.13"
}

provider "proxmox" {
  pm_api_url          = "https://192.168.3.203:8006/api2/json"
  pm_api_token_id     = "OpenTofu@pam!opentofu"
  pm_api_token_secret = "ada5bc72-de51-4832-b9f5-6b49a284d21b"
  pm_tls_insecure     = true
  pm_debug            = true
}
