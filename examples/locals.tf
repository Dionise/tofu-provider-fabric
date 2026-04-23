locals {
  image_catalog = {
    "debian-12-v2026.04" = {
      aws = {
        ami_id = "ami-0123456789abcdef0"
      }
      openstack = {
        image_id = "01234567-89ab-cdef-0123-456789abcdef"
      }
    }
  }

  machine_profiles = {
    small = {
      aws_instance_type = "t3.medium"
      vcpus             = 2
      memory_gb         = 4
      disk_gb           = 20
    }
    medium = {
      aws_instance_type = "m5.large"
      vcpus             = 4
      memory_gb         = 8
      disk_gb           = 40
    }
    large = {
      aws_instance_type = "m5.xlarge"
      vcpus             = 8
      memory_gb         = 16
      disk_gb           = 80
    }
  }

  web_instance = local.machine_profiles[var.machine_profile]

  common_tags = {
    env     = "prod"
    service = var.deployment_name
  }
}
