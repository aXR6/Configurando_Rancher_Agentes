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
  pm_api_url          = "https://192.168.2.50:8006/api2/json"
  pm_api_token_id     = "terraform@pam!tATO0820jSdoNml9FF6dPo"
  pm_api_token_secret = "2f50ea98-0fc3-4af9-b0cc-90de83161c0c"
  pm_tls_insecure     = true
  pm_debug            = true
}