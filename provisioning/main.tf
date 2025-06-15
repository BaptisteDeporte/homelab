terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.71.0"
    }
  }
}

variable "pve_url" {
  type = string
}

variable "pve_token" {
  type = string
}

variable "vm_ip" {
  type = string
}

provider "proxmox" {
  endpoint  = var.pve_url
  api_token = var.pve_token
  insecure  = true
  tmp_dir   = "/var/tmp"

  ssh {
    agent       = false
    username    = "terraform"
    private_key = file("~/.ssh/terraform/id_terraform")
  }
}

resource "tls_private_key" "ansible_vm_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "random_password" "ansible_vm_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

resource "proxmox_virtual_environment_download_file" "debian-12-pve-01" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve-01"
  url          = "https://cdimage.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
  file_name    = "debian12.img"
}

resource "proxmox_virtual_environment_download_file" "debian-12-pve-02" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve-02"
  url          = "https://cdimage.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
  file_name    = "debian12.img"
}

resource "proxmox_virtual_environment_vm" "k3s-node-01" {
  name      = "k3s-node-01"
  node_name = "pve-01"

  # should be true if qemu agent is not installed / enabled on the VM
  stop_on_destroy = true

  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
  }

  serial_device {
    device = "socket"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.2.5/16"
        gateway = "192.168.1.1"
      }
    }

    user_account {
      username = "ansible"
      keys     = [trimspace(tls_private_key.ansible_vm_key.public_key_openssh)]
      password = random_password.ansible_vm_password.result
    }
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.debian-12-pve-01.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }

  operating_system {
    type = "l26"
  }

  network_device {
    bridge = "vmbr0"
  }

}

resource "proxmox_virtual_environment_vm" "k3s-node-02" {
  name      = "k3s-node-02"
  node_name = "pve-02"

  # should be true if qemu agent is not installed / enabled on the VM
  stop_on_destroy = true

  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
  }

  serial_device {
    device = "socket"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.2.4/16"
        gateway = "192.168.1.1"
      }
    }

    user_account {
      username = "ansible"
      keys     = [trimspace(tls_private_key.ansible_vm_key.public_key_openssh)]
      password = random_password.ansible_vm_password.result
    }
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.debian-12-pve-02.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }

  operating_system {
    type = "l26"
  }

  network_device {
    bridge = "vmbr0"
  }

}

output "ansible_vm_private_key" {
  value     = tls_private_key.ansible_vm_key.private_key_pem
  sensitive = true
}

output "ansible_vm_public_key" {
  value = tls_private_key.ansible_vm_key.public_key_openssh
}

output "ansible_vm_password" {
  value     = random_password.ansible_vm_password.result
  sensitive = true
}
