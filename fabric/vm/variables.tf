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

variable "vcpus" {
  type        = number
  default     = 2
  description = "Number of vCPUs used for OpenStack flavor lookup."
}

variable "memory_gb" {
  type        = number
  default     = 4
  description = "Memory in GB used with vcpus for OpenStack flavor lookup."
}

variable "disk_gb" {
  type        = number
  default     = 20
  description = "Root disk size in GB."
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

variable "aws_network" {
  type        = string
  default     = ""
  description = "AWS subnet ID to launch the instance in."
}

variable "aws_instance_type" {
  type        = string
  default     = ""
  description = "AWS instance type such as t3.medium."
  validation {
    condition     = !contains(tolist(var.clouds), "aws") || var.aws_instance_type != ""
    error_message = "aws_instance_type must be set when clouds includes aws."
  }
}

variable "openstack_network" {
  type        = string
  default     = ""
  description = "OpenStack network UUID to attach the instance to."
}
