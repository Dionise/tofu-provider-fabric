variable "deployment_name" {
  type        = string
  default     = "example"
  description = "Base name used for the example deployment."
}

variable "clouds" {
  type        = set(string)
  default     = ["openstack"]
  description = "Clouds enabled for the example deployment."
}

variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for the example provider."
}

variable "openstack_auth_url" {
  type        = string
  default     = ""
  description = "OpenStack identity endpoint."
}

variable "openstack_user_name" {
  type        = string
  default     = ""
  description = "OpenStack user name."
}

variable "openstack_tenant_name" {
  type        = string
  default     = ""
  description = "OpenStack project or tenant name."
}

variable "openstack_password" {
  type        = string
  default     = ""
  sensitive   = true
  description = "OpenStack password."
}

variable "image_release" {
  type        = string
  default     = "debian-12-generic-amd64-20250210-2019"
  description = "Release name selected from the local image catalog."
}

variable "machine_profile" {
  type        = string
  default     = "small"
  description = "Named machine profile used by the example stack."
}

variable "ssh_key" {
  type        = string
  default     = "my-key"
  description = "Key name used for both clouds in the example."
}

variable "allocate_public_ip" {
  type        = bool
  default     = false
  description = "When true, allocate a stable public IP on every enabled cloud."
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
  description = "AWS-only security group rules for rules not expressible in security_group_rules."
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
  description = "OpenStack-only security group rules for rules not expressible in security_group_rules."
}

variable "security_group_rules" {
  type = list(object({
    direction = string
    protocol  = string
    port_min  = optional(number)
    port_max  = optional(number)
    cidr      = string
  }))
  default = [
    { direction = "ingress", protocol = "tcp", port_min = 22, port_max = 22, cidr = "0.0.0.0/0" },
    { direction = "ingress", protocol = "tcp", port_min = 80, port_max = 80, cidr = "0.0.0.0/0" },
    { direction = "ingress", protocol = "tcp", port_min = 443, port_max = 443, cidr = "0.0.0.0/0" },
    { direction = "ingress", protocol = "icmp", cidr = "0.0.0.0/0" },
    { direction = "egress", protocol = "-1", cidr = "0.0.0.0/0" },
  ]
  description = "Security group rules applied to all VMs on every enabled cloud."
}

variable "aws_network_mode" {
  type        = string
  default     = "existing"
  description = "Whether the example attaches to an existing AWS subnet or creates one."
}

variable "aws_network" {
  type        = string
  default     = "subnet-0abc123"
  description = "Existing AWS subnet ID used when aws_network_mode is existing."
}

variable "openstack_network_mode" {
  type        = string
  default     = "managed"
  description = "Whether the example attaches to an existing OpenStack network or creates one."
}

variable "openstack_network" {
  type        = string
  default     = ""
  description = "Existing OpenStack network UUID used when openstack_network_mode is existing."
}

variable "openstack_external_network_name" {
  type        = string
  default     = "Admin"
  description = "External OpenStack network name used when the example creates a managed tenant network."
}
