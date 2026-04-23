locals {
  use_aws       = contains(tolist(var.clouds), "aws")
  use_openstack = contains(tolist(var.clouds), "openstack")

  selected_release   = try(var.image_catalog[var.image_release], null)
  aws_ami_id         = try(local.selected_release.aws.ami_id, null)
  openstack_image_id = try(local.selected_release.openstack.image_id, null)
}

resource "aws_instance" "this" {
  count         = local.use_aws ? 1 : 0
  ami           = local.aws_ami_id
  instance_type = var.aws_instance_type
  subnet_id     = var.aws_network != "" ? var.aws_network : null
  key_name      = var.ssh_key != "" ? var.ssh_key : null

  lifecycle {
    precondition {
      condition     = local.aws_ami_id != null && local.aws_ami_id != ""
      error_message = "Selected image_release must include aws.ami_id when deploying to AWS."
    }
    precondition {
      condition     = var.aws_instance_type != ""
      error_message = "aws_instance_type must be set when deploying to AWS."
    }
  }

  root_block_device {
    volume_size = var.disk_gb
  }

  tags = merge(var.tags, { Name = var.name })
}

data "openstack_compute_flavor_v2" "this" {
  count = local.use_openstack ? 1 : 0
  vcpus = var.vcpus
  ram   = var.memory_gb * 1024
}

resource "openstack_compute_instance_v2" "this" {
  count     = local.use_openstack ? 1 : 0
  name      = var.name
  flavor_id = data.openstack_compute_flavor_v2.this[0].id
  key_pair  = var.ssh_key != "" ? var.ssh_key : null
  metadata  = var.tags

  lifecycle {
    precondition {
      condition     = local.openstack_image_id != null && local.openstack_image_id != ""
      error_message = "Selected image_release must include openstack.image_id when deploying to OpenStack."
    }
  }

  block_device {
    uuid                  = local.openstack_image_id
    source_type           = "image"
    volume_size           = var.disk_gb
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  dynamic "network" {
    for_each = var.openstack_network != "" ? [var.openstack_network] : []
    content {
      uuid = network.value
    }
  }
}
