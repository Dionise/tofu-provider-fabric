locals {
  image_catalog = {
    "debian-12-generic-amd64-20250210-2019" = {
      aws = {
        ami_id = "ami-0123456789abcdef0"
      }
      openstack = {
        image_id = "3b64d4a7-8530-4a39-9c23-81dae1d5075d"
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

  common_tags = {
    env     = "prod"
    service = var.deployment_name
  }
}
