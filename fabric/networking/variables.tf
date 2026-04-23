variable "name" {
  type        = string
  default     = "fabric"
  description = "Base name used for managed network resources."
}

variable "clouds" {
  type        = set(string)
  default     = []
  description = "Which clouds this network belongs to."
  validation {
    condition     = alltrue([for cloud in var.clouds : contains(["aws", "openstack"], cloud)])
    error_message = "clouds can contain only: aws, openstack."
  }
}

variable "aws_network_mode" {
  type        = string
  default     = "existing"
  description = "How AWS networking is handled: existing or managed."
  validation {
    condition     = contains(["existing", "managed"], var.aws_network_mode)
    error_message = "aws_network_mode must be either existing or managed."
  }
}

variable "aws_network" {
  type        = string
  default     = ""
  description = "Existing AWS subnet ID when aws_network_mode is existing."
  validation {
    condition     = !contains(tolist(var.clouds), "aws") || var.aws_network_mode != "existing" || var.aws_network != ""
    error_message = "aws_network must be set when clouds includes aws and aws_network_mode is existing."
  }
}

variable "aws_vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for a managed AWS VPC."
}

variable "aws_subnet_cidr" {
  type        = string
  default     = "10.0.1.0/24"
  description = "CIDR block for a managed AWS subnet."
}

variable "aws_availability_zone" {
  type        = string
  default     = ""
  description = "Availability zone for a managed AWS subnet. Leave empty to let AWS choose."
}

variable "openstack_network_mode" {
  type        = string
  default     = "existing"
  description = "How OpenStack networking is handled: existing or managed."
  validation {
    condition     = contains(["existing", "managed"], var.openstack_network_mode)
    error_message = "openstack_network_mode must be either existing or managed."
  }
}

variable "openstack_network" {
  type        = string
  default     = ""
  description = "Existing OpenStack network UUID when openstack_network_mode is existing."
  validation {
    condition     = !contains(tolist(var.clouds), "openstack") || var.openstack_network_mode != "existing" || var.openstack_network != ""
    error_message = "openstack_network must be set when clouds includes openstack and openstack_network_mode is existing."
  }
}

variable "openstack_subnet_cidr" {
  type        = string
  default     = "10.0.0.0/24"
  description = "CIDR block for a managed OpenStack subnet."
}

variable "openstack_dns_nameservers" {
  type        = list(string)
  default     = []
  description = "DNS nameservers for a managed OpenStack subnet."
}

variable "openstack_enable_dhcp" {
  type        = bool
  default     = true
  description = "Whether DHCP is enabled on a managed OpenStack subnet."
}

variable "openstack_external_network_id" {
  type        = string
  default     = ""
  description = "External OpenStack network UUID used to route a managed tenant network."
}
