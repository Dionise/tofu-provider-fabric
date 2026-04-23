locals {
  use_aws       = contains(tolist(var.clouds), "aws")
  use_openstack = contains(tolist(var.clouds), "openstack")
}

resource "aws_eip" "this" {
  count    = local.use_aws && var.allocate ? 1 : 0
  domain   = "vpc"
  instance = var.aws_instance_id

  tags = merge(var.tags, { Name = "${var.name}-eip" })
}

resource "openstack_networking_floatingip_v2" "this" {
  count = local.use_openstack && var.allocate ? 1 : 0
  pool  = var.openstack_floating_ip_pool
}

resource "openstack_compute_floatingip_associate_v2" "this" {
  count                 = local.use_openstack && var.allocate ? 1 : 0
  floating_ip           = openstack_networking_floatingip_v2.this[0].address
  instance_id           = var.openstack_instance_id
  wait_until_associated = true
}
