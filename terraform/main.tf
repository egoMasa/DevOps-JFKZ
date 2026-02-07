# ============================================================
# Terraform – Provider Proxmox
# ------------------------------------------------------------
# Configuration du provider bpg/proxmox
# Utilise l'API Proxmox via token
# ============================================================

provider "proxmox" {
  endpoint  = var.proxmox_api_url
  api_token = "${var.proxmox_token_id}=${var.proxmox_token_secret}"
  insecure  = true
}

locals {
  total_vms = 1 + var.worker_count + 1
  # index 0 => master
  # index 1..worker_count => workers
  # index total_vms-1 => db
  master_index = 0
  db_index     = local.total_vms - 1

  master_ip = "${var.vm_ip_base}${var.vm_ip_start + local.master_index}"
  db_ip     = "${var.vm_ip_base}${var.vm_ip_start + local.db_index}"

  worker_ips = [
    for i in range(1, 1 + var.worker_count) :
    "${var.vm_ip_base}${var.vm_ip_start + i}"
  ]
}

resource "proxmox_virtual_environment_vm" "vm" {
  count = local.total_vms

  name = (
    count.index == local.master_index ? "tf-k8s-master" :
    count.index == local.db_index     ? "tf-db-postgres" :
    "tf-k8s-node-${count.index}"
  )

  vm_id     = var.vmid_start + count.index
  node_name = var.proxmox_node

  clone {
    vm_id = var.template_vmid
    full  = true
  }

  agent {
    enabled = true
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 8192
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 30
  }

  network_device {
    bridge = var.vm_bridge
    model  = "virtio"
  }

  initialization {
    user_account {
      username = "ansible"
      keys     = [var.ssh_public_key]
    }

    ip_config {
      ipv4 {
        address = "${var.vm_ip_base}${var.vm_ip_start + count.index}/${var.vm_cidr}"
        gateway = var.vm_gateway
      }
    }
  }

  operating_system {
    type = "l26"
  }
}

resource "local_file" "ansible_inventory" {
  filename = "../ansible/inventory.ini"

  content = templatefile("inventory.tftpl", {
    master_ip  = local.master_ip
    worker_ips = local.worker_ips
    db_ip      = local.db_ip
  })
}
