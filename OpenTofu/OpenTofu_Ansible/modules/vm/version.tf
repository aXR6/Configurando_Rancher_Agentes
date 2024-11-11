terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      #version = "2.9.11"     
      #version = "2.9.14"     # Versão estável recomendada
      version = "3.0.1-rc4"   # Versão mais recente. Funcionando com esse projeto. (Caso seja mudada a versão, ajustes precisam ser feito.)
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"       # Versão estável
    }
  }
  required_version = ">= 1.0" # Versão mais recente para compatibilidade
}

variable "pm_api_url" {
  description = "Proxmox API URL"
  type        = string
  default     = "https://192.168.3.203:8006/api2/json"
}

variable "pm_api_token_id" {
  description = "Proxmox API token ID"
  type        = string
  sensitive   = true
  default     = "OpenTofu@pam!opentofu"
}

variable "pm_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
  default     = "ada5bc72-de51-4832-b9f5-6b49a284d21b"
}

provider "proxmox" {
  pm_api_url          = var.pm_api_url
  pm_api_token_id     = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure     = true    # Certificado TLS deve ser válido em produção
  pm_debug            = false   # Debug desativado para produção
}