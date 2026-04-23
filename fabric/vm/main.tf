locals {
  use_aws       = contains(tolist(var.clouds), "aws")
  use_openstack = contains(tolist(var.clouds), "openstack")

  selected_release   = try(var.image_catalog[var.image_release], null)
  aws_ami_id         = try(local.selected_release.aws.ami_id, null)
  openstack_image_id = try(local.selected_release.openstack.image_id, null)

  profile   = try(var.machine_catalog[var.machine_profile], null)
  create_sg = length(var.security_group_rules) > 0 || length(var.aws_extra_rules) > 0 || length(var.openstack_extra_rules) > 0
}

# --- security groups -------------------------------------------------------

data "aws_subnet" "this" {
  count = local.use_aws && local.create_sg && var.aws_network != "" ? 1 : 0
  id    = var.aws_network
}

module "sg" {
  count  = local.create_sg ? 1 : 0
  source = "../security-groups"

  name   = var.name
  clouds = var.clouds
  tags   = var.tags

  rules                 = var.security_group_rules
  aws_extra_rules       = var.aws_extra_rules
  openstack_extra_rules = var.openstack_extra_rules
  aws_vpc_id            = length(data.aws_subnet.this) > 0 ? data.aws_subnet.this[0].vpc_id : ""
}

# --- compute ---------------------------------------------------------------

resource "aws_instance" "this" {
  count                  = local.use_aws ? 1 : 0
  ami                    = local.aws_ami_id
  instance_type          = local.profile.aws_instance_type
  subnet_id              = var.aws_network != "" ? var.aws_network : null
  key_name               = var.ssh_key != "" ? var.ssh_key : null
  vpc_security_group_ids = local.create_sg ? [module.sg[0].aws.security_group_id] : null

  lifecycle {
    precondition {
      condition     = local.aws_ami_id != null && local.aws_ami_id != ""
      error_message = "Selected image_release must include aws.ami_id when deploying to AWS."
    }
    precondition {
      condition     = local.profile.aws_instance_type != ""
      error_message = "machine_profile must include a non-empty aws_instance_type when deploying to AWS."
    }
  }

  root_block_device {
    volume_size = local.profile.disk_gb
  }

  tags = merge(var.tags, { Name = var.name })
}

data "openstack_compute_flavor_v2" "this" {
  count = local.use_openstack ? 1 : 0
  vcpus = local.profile.vcpus
  ram   = local.profile.memory_gb * 1024
}

resource "openstack_compute_instance_v2" "this" {
  count           = local.use_openstack ? 1 : 0
  name            = var.name
  flavor_id       = data.openstack_compute_flavor_v2.this[0].id
  key_pair        = var.ssh_key != "" ? var.ssh_key : null
  security_groups = local.create_sg ? [module.sg[0].openstack.security_group_name] : null
  metadata        = var.tags

  lifecycle {
    precondition {
      condition     = local.openstack_image_id != null && local.openstack_image_id != ""
      error_message = "Selected image_release must include openstack.image_id when deploying to OpenStack."
    }
  }

  block_device {
    uuid                  = local.openstack_image_id
    source_type           = "image"
    volume_size           = local.profile.disk_gb
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
