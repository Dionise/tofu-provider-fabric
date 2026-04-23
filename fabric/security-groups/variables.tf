variable "name" {
  type        = string
  default     = "sg"
  description = "Base name used for security group resources."
}

variable "clouds" {
  type        = set(string)
  default     = []
  description = "Which clouds to create security groups on. Valid values: \"aws\", \"openstack\"."
  validation {
    condition     = alltrue([for cloud in var.clouds : contains(["aws", "openstack"], cloud)])
    error_message = "clouds can contain only: aws, openstack."
  }
}

variable "rules" {
  type = list(object({
    direction = string
    protocol  = string
    port_min  = optional(number)
    port_max  = optional(number)
    cidr      = string
  }))
  default     = []
  description = "Rules applied to every cloud in clouds."
  validation {
    condition     = alltrue([for r in var.rules : contains(["ingress", "egress"], r.direction)])
    error_message = "rule direction must be ingress or egress."
  }
  validation {
    condition     = alltrue([for r in var.rules : contains(["tcp", "udp", "icmp", "-1"], r.protocol)])
    error_message = "rule protocol must be tcp, udp, icmp, or -1."
  }
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
  description = "AWS-only rules. Use for IPv6 CIDRs or SG-to-SG references not expressible in rules."
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
  description = "OpenStack-only rules. Use for remote group references or non-IPv4 ethertype not expressible in rules."
}

variable "aws_vpc_id" {
  type        = string
  default     = ""
  description = "AWS VPC ID the security group is created in. Required when clouds includes aws."
  validation {
    condition     = !contains(tolist(var.clouds), "aws") || var.aws_vpc_id != ""
    error_message = "aws_vpc_id must be set when clouds includes aws."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Key/value tags applied to all resources that support tagging."
}
