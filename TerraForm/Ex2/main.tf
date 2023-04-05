# provider block para o Proxmox
provider "proxmox" {
  pm_api_url = "https://192.168.2.50:8006/api2/json"
  pm_user = "root"
  pm_password = "902grego1989"
  target_node = "pvedell5437"
  pm_tls_insecure = true
}

# criação da máquina virtual
resource "proxmox_vm_qemu" "vm_debian" {
  name                 = "vm_debian"
  target_node          = "pvedell5437"
  memory               = 3584 # 3.5GB de RAM
  cores                = 2
  sockets              = 1
  ide2                 = "/usr/share/qemu-server/cloudinit/Cloud-Init.iso"
  net0                 = "model=virtio,bridge=vmbr0"
  scsihw               = "virtio-scsi-pci"
  scsi0                = "data:vm-100-disk-0,size=40G"
  scsi1                = "data:vm-100-disk-1,size=2G"
  os_type              = "debianbullseye"
  agent                = 1
  hotplug              = "network,disk,usb"
  onboot               = true
  startup              = "order=1"
  qemu_os_drive        = "scsi0"
  cloudinit            = "user-data=@./cloudinit.yaml"
  serial0              = "socket"
  vga                  = "none"
  balloon              = 0
  rtcbase              = "utc"
  hookscript           = "/usr/share/qemu-server/pve-bridge-hook"
  force_create_on_disk = true
  password             = "proxmox"
  sshkeys              = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO6ZglzIaXb6Oi/45JWm/31yQyhJeckq18q2Qds/zk17"
}

# criação do arquivo cloud-init
resource "local_file" "cloudinit" {
  content = <<EOF
#cloud-config
hostname: vm_debian
users:
  - name: proxmox
    lock_passwd: false
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO6ZglzIaXb6Oi/45JWm/31yQyhJeckq18q2Qds/zk17
EOF
  filename = "cloudinit.yaml"
}
