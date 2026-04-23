variable "deployment_name" {
  type        = string
  default     = "example"
  description = "Base name used for the example deployment."
}

variable "clouds" {
  type        = set(string)
  default     = []
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
  default     = "debian-12-v2026.04"
  description = "Release name selected from the local image catalog."
}

variable "machine_profile" {
  type        = string
  default     = "small"
  description = "Named machine profile used by the example stack."
  validation {
    condition     = contains(["small", "medium", "large"], var.machine_profile)
    error_message = "machine_profile must be one of: small, medium, large."
  }
}

variable "ssh_key" {
  type        = string
  default     = "my-key"
  description = "Key name used for both clouds in the example."
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

variable "openstack_external_network_id" {
  type        = string
  default     = "ext-net-uuid-abcde"
  description = "External OpenStack network UUID used when the example creates a managed tenant network."
}
