# Provider Proxmox
terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}

resource "proxmox_vm_qemu" "vm" {
  name = "my-vm"
  memory = 4096
  cores = 2
  sockets = 1
  disk_size = 40
  storage = "nfs"
  scsihw = "virtio-scsi-pci"
  bios = "seabios"
  ide2 = "/usr/share/qemu-server/ovmf-x86_64-ms-code.bin,media=cdrom"
  bootdisk = "scsi0"
  os_type = "l26"
  net0_model = "virtio"
  net0_bridge = "vmbr0"
  net0_firewall = 1
  ssh_forward_port = 22
  cloudinit = 1
}
