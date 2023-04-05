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
 
  #pm_user             = "root"
  #pm_password         = "902grego1989"
  #pm_tls_insecure     = true
  #pm_debug            = true

  pm_api_token_id     = "root"
  pm_api_token_secret = "902grego1989"
  pm_tls_insecure     = true
  pm_debug            = true
}