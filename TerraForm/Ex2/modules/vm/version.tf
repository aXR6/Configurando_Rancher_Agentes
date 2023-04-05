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
  pm_api_url          = "https://<your proxmox server>:8006/api2/json"
  pm_api_token_id     = "<your pve user>"
  pm_api_token_secret = "<your secret for the pve user>"
  pm_tls_insecure     = true
  pm_debug            = true
}