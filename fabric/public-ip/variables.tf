variable "name" {
  type        = string
  default     = "public-ip"
  description = "Base name used for public IP resources."
}

variable "clouds" {
  type        = set(string)
  default     = []
  description = "Which clouds can allocate public IP resources."
  validation {
    condition     = alltrue([for cloud in var.clouds : contains(["aws", "openstack"], cloud)])
    error_message = "clouds can contain only: aws, openstack."
  }
}

variable "allocate" {
  type        = bool
  default     = false
  description = "When true, allocate a stable public IP on every cloud in clouds."
}

variable "aws_instance_id" {
  type        = string
  default     = ""
  description = "AWS instance ID that an Elastic IP should attach to."
  validation {
    condition     = !contains(tolist(var.clouds), "aws") || !var.allocate || var.aws_instance_id != ""
    error_message = "aws_instance_id must be set when allocate is true and clouds includes aws."
  }
}

variable "openstack_instance_id" {
  type        = string
  default     = ""
  description = "OpenStack instance ID that a floating IP should attach to."
  validation {
    condition     = !contains(tolist(var.clouds), "openstack") || !var.allocate || var.openstack_instance_id != ""
    error_message = "openstack_instance_id must be set when allocate is true and clouds includes openstack."
  }
}

variable "openstack_floating_ip_pool" {
  type        = string
  default     = ""
  description = "OpenStack floating IP pool name. Required when allocate is true and clouds includes openstack."
  validation {
    condition     = !contains(tolist(var.clouds), "openstack") || !var.allocate || var.openstack_floating_ip_pool != ""
    error_message = "openstack_floating_ip_pool must be set when allocate is true and clouds includes openstack."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Key/value tags applied to resources that support tagging."
}
