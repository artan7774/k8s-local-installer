
variable "domain_name" {
  type = string
  description = "Domain name"
}


variable "domain_memory" {
  type = string
  description = "RAM for the domain"
}


variable "domain_vcpu" {
  type = string
  description = "vCPU for the domain"
}


variable "pool_name" {
  type = string
  description = "Name of the domain pool"
}


variable "network_name" {
  type = string
  description = "Name of the domain network"
}


# variable "network_domain" {
#   type = string
#   description = "Domain's DNS zone"
# }

variable "network_zone" {
  type = string
  description = "Domain's DNS zone"
}

variable "network_address" {
  type = string
  description = "Domain's IP address"
}

# variable "network_mask" {
#   type = string
#   description = "Domain's IP addresses' mask"
# }

variable "network_bits" {
  type = string
  description = "Domain IP addresses' bits"
}

variable "network_gateway" {
  type = string
  description = "IP addresses' gateway"
}

variable "ssh_public_key_path" {
  type = string
  description = "Path to your local ID_RSA.pub key"
}

variable "source_image" {
  type = string
  default = "https://cloud.debian.org/images/cloud/sid/daily/latest/debian-sid-genericcloud-amd64-daily.qcow2"
  description = "Path to source image for each instance"
}