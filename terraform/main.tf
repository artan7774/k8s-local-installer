
terraform {
  required_providers {
    libvirt = {
        source = "dmacvicar/libvirt"
        version = "0.7.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"

}

locals {
  project_name = "k8s"
  network_domain = "k8s.local"
  network_mask = "10.9.8.0"
  network_bits = 24
}

resource "libvirt_network" "network" {
  name      = local.project_name

  autostart = true
  mode      = "nat"
  domain    = local.network_domain
  addresses = ["${local.network_mask}/${local.network_bits}"]
  dns {
    enabled = true
    local_only = true
  }
}

resource "libvirt_pool" "pool" {
  name = local.project_name
  type = "dir"
  path = "/home/user/qemu/${local.project_name}"
}

module "masters" {
  count = 1

  source = "./domain"
  domain_name = "${local.project_name}-master${count.index}"
  network_zone = local.network_domain
  domain_memory = "2048"
  domain_vcpu = "2"

  pool_name = libvirt_pool.pool.name

  network_name = libvirt_network.network.name
  network_address = cidrhost("${local.network_mask}/${local.network_bits}", sum([10, count.index]))
  network_bits = local.network_bits
  network_gateway = "10.9.8.1"

  source_image = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64-disk-kvm.img"

  ssh_public_key_path = "/home/user/.ssh/id_rsa.pub"
}

module "nodes" {
  count = 1

  source = "./domain"

  domain_name = "${local.project_name}-node${count.index}"
  network_zone = local.network_domain
  domain_memory = "2048"
  domain_vcpu = "1"

  pool_name = libvirt_pool.pool.name

  network_name = libvirt_network.network.name
  network_address = cidrhost("${local.network_mask}/${local.network_bits}", sum([20, count.index]))
  network_bits = local.network_bits
  network_gateway = "10.9.8.1"

  source_image = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64-disk-kvm.img"

  ssh_public_key_path = "/home/user/.ssh/id_rsa.pub"
}

resource "local_file" "inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl",
    {
      masters = module.masters
      nodes = module.nodes
    }
  )
  filename = "./inventory.ini"
}