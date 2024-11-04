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
  pm_api_token_id     = "opentofu@pam!opentofu"
  pm_api_token_secret = "f0afe7fa-eac6-4b49-aa2b-56b9971215c5"
  pm_tls_insecure     = true
  pm_debug            = true
}