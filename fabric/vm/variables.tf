variable "name" {
  type        = string
  default     = "vm"
  description = "Instance name."
}

variable "clouds" {
  type        = set(string)
  default     = []
  description = "Which clouds to deploy on. Valid values: \"aws\", \"openstack\"."
  validation {
    condition     = alltrue([for cloud in var.clouds : contains(["aws", "openstack"], cloud)])
    error_message = "clouds can contain only: aws, openstack."
  }
}

variable "image_release" {
  type        = string
  default     = ""
  description = "Name of the image release to deploy."
  validation {
    condition     = length(var.clouds) == 0 || (var.image_release != "" && contains(keys(var.image_catalog), var.image_release))
    error_message = "image_release must match a key in image_catalog."
  }
  validation {
    condition     = !contains(tolist(var.clouds), "aws") || try(var.image_catalog[var.image_release].aws.ami_id != "", false)
    error_message = "Selected image_release must include aws.ami_id when clouds includes aws."
  }
  validation {
    condition     = !contains(tolist(var.clouds), "openstack") || try(var.image_catalog[var.image_release].openstack.image_id != "", false)
    error_message = "Selected image_release must include openstack.image_id when clouds includes openstack."
  }
}

variable "image_catalog" {
  type = map(object({
    aws = optional(object({
      ami_id = string
    }))
    openstack = optional(object({
      image_id = string
    }))
  }))
  default     = {}
  description = "Release catalog keyed by release name. Each release maps to cloud-specific image IDs."
}

variable "machine_catalog" {
  type = map(object({
    aws_instance_type = string
    vcpus             = number
    memory_gb         = number
    disk_gb           = number
  }))
  default     = {}
  description = "Profile catalog keyed by profile name."
}

variable "machine_profile" {
  type        = string
  default     = "small"
  description = "Profile name selected from machine_catalog."
  validation {
    condition     = length(var.machine_catalog) == 0 || contains(keys(var.machine_catalog), var.machine_profile)
    error_message = "machine_profile must match a key in machine_catalog."
  }
}

variable "ssh_key" {
  type        = string
  default     = ""
  description = "SSH key name to inject. Must already exist in each cloud."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Key/value tags applied to all resources on every cloud."
}

variable "security_group_rules" {
  type = list(object({
    direction = string
    protocol  = string
    port_min  = optional(number)
    port_max  = optional(number)
    cidr      = string
  }))
  default     = []
  description = "Security group rules applied to the instance on every cloud."
}

variable "aws_extra_rules" {
  type = list(object({
    direction                    = string
    protocol                     = string
    port_min                     = optional(number)
    port_max                     = optional(number)
    cidr                         = optional(string)
    cidr_ipv6                    = optional(string)
    referenced_security_group_id = optional(string)
  }))
  default     = []
  description = "AWS-only security group rules. Use for IPv6 CIDRs or SG-to-SG references not expressible in security_group_rules."
}

variable "openstack_extra_rules" {
  type = list(object({
    direction       = string
    protocol        = optional(string)
    port_min        = optional(number)
    port_max        = optional(number)
    cidr            = optional(string)
    remote_group_id = optional(string)
    ethertype       = optional(string, "IPv4")
  }))
  default     = []
  description = "OpenStack-only security group rules. Use for remote group references or IPv6 rules not expressible in security_group_rules."
}

variable "aws_network" {
  type        = string
  default     = ""
  description = "AWS subnet ID to launch the instance in."
}

variable "openstack_network" {
  type        = string
  default     = ""
  description = "OpenStack network UUID to attach the instance to."
}
