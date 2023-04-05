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
  pm_api_token_id     = "terraform-prov@pve!ORugzo3o1MoU59aQZ2364K8us"
  pm_api_token_secret = "aa90365c-8c5f-4e5c-b1be-e22b769f7d32"
  pm_tls_insecure     = true
  pm_debug            = true
}