
terraform {
  required_providers {
    libvirt = {
        source = "dmacvicar/libvirt"
        version = "0.7.0"
    }
  }
}

resource "libvirt_volume" "volume" {
  name   = "${var.domain_name}-root"
  pool = var.pool_name
  source = var.source_image
  format = "qcow2"
}

data "template_file" "user_data" {
  template = file("${path.module}/files/cloud_init.cfg")
  vars = {
    domain_name = var.domain_name
    network_zone = var.network_zone
    ssh_public_key = file(var.ssh_public_key_path)
  }
}

data "template_file" "network_config" {
  template = file("${path.module}/files/network_config.cfg")
  vars = {
    network_zone = var.network_zone
    network_address = var.network_address
    network_bits = var.network_bits
    network_gateway = var.network_gateway
  }
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "${var.domain_name}-commoninit"
  user_data = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
  pool = var.pool_name
}

resource "libvirt_domain" "domain" {
  name = var.domain_name
  memory = var.domain_memory
  vcpu = var.domain_vcpu

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name = var.network_name
  }

  console {
    type = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.volume.id
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}