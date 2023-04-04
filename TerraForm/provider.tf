# Provider Proxmox
terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}
provider "proxmox" {
pm_api_url = "https://proxmox-ks8.ddns.net:8006/api2/json"
pm_user = "root"
pm_password = "902grego1989"
pm_tls_insecure = false
# deixe isso como true se você estiver usando SSL auto-assinado
}