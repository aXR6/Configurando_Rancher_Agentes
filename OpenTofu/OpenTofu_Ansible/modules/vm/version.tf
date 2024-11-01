terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9.11"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.3.0"
    }
  }
  required_version = ">= 0.13"
}

provider "proxmox" {
  pm_api_url          = "https://192.168.3.203:8006/api2/json"
  pm_api_token_id     = "opentofu@pam!tofu-token"
  pm_api_token_secret = "b571e4a1-7fd0-4bb2-acd9-f4f4fa392c4e"
  pm_tls_insecure     = true
  pm_debug            = true
}