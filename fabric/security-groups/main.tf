locals {
  use_aws       = contains(tolist(var.clouds), "aws")
  use_openstack = contains(tolist(var.clouds), "openstack")

  rules_map     = { for i, r in var.rules : tostring(i) => r }
  ingress_rules = { for k, r in local.rules_map : k => r if r.direction == "ingress" }
  egress_rules  = { for k, r in local.rules_map : k => r if r.direction == "egress" }

  aws_extra_map     = { for i, r in var.aws_extra_rules : tostring(i) => r }
  aws_extra_ingress = { for k, r in local.aws_extra_map : k => r if r.direction == "ingress" }
  aws_extra_egress  = { for k, r in local.aws_extra_map : k => r if r.direction == "egress" }
  os_extra_map      = { for i, r in var.openstack_extra_rules : tostring(i) => r }
}

resource "aws_security_group" "this" {
  count  = local.use_aws ? 1 : 0
  name   = var.name
  vpc_id = var.aws_vpc_id
  tags   = merge(var.tags, { Name = var.name })
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each          = local.use_aws ? local.ingress_rules : {}
  security_group_id = aws_security_group.this[0].id
  cidr_ipv4         = each.value.cidr
  ip_protocol       = each.value.protocol
  from_port         = each.value.protocol != "-1" ? each.value.port_min : null
  to_port           = each.value.protocol != "-1" ? each.value.port_max : null
  tags              = var.tags
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each          = local.use_aws ? local.egress_rules : {}
  security_group_id = aws_security_group.this[0].id
  cidr_ipv4         = each.value.cidr
  ip_protocol       = each.value.protocol
  from_port         = each.value.protocol != "-1" ? each.value.port_min : null
  to_port           = each.value.protocol != "-1" ? each.value.port_max : null
  tags              = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "extra" {
  for_each                     = local.use_aws ? local.aws_extra_ingress : {}
  security_group_id            = aws_security_group.this[0].id
  ip_protocol                  = each.value.protocol
  from_port                    = each.value.protocol != "-1" ? each.value.port_min : null
  to_port                      = each.value.protocol != "-1" ? each.value.port_max : null
  cidr_ipv4                    = each.value.cidr
  cidr_ipv6                    = each.value.cidr_ipv6
  referenced_security_group_id = each.value.referenced_security_group_id
  tags                         = var.tags
}

resource "aws_vpc_security_group_egress_rule" "extra" {
  for_each                     = local.use_aws ? local.aws_extra_egress : {}
  security_group_id            = aws_security_group.this[0].id
  ip_protocol                  = each.value.protocol
  from_port                    = each.value.protocol != "-1" ? each.value.port_min : null
  to_port                      = each.value.protocol != "-1" ? each.value.port_max : null
  cidr_ipv4                    = each.value.cidr
  cidr_ipv6                    = each.value.cidr_ipv6
  referenced_security_group_id = each.value.referenced_security_group_id
  tags                         = var.tags
}

resource "openstack_networking_secgroup_v2" "this" {
  count                = local.use_openstack ? 1 : 0
  name                 = var.name
  description          = var.name
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "this" {
  for_each          = local.use_openstack ? local.rules_map : {}
  direction         = each.value.direction
  ethertype         = "IPv4"
  protocol          = each.value.protocol != "-1" ? each.value.protocol : null
  port_range_min    = each.value.port_min
  port_range_max    = each.value.port_max
  remote_ip_prefix  = each.value.cidr
  security_group_id = openstack_networking_secgroup_v2.this[0].id
}

resource "openstack_networking_secgroup_rule_v2" "extra" {
  for_each          = local.use_openstack ? local.os_extra_map : {}
  direction         = each.value.direction
  ethertype         = each.value.ethertype
  protocol          = each.value.protocol
  port_range_min    = each.value.port_min
  port_range_max    = each.value.port_max
  remote_ip_prefix  = each.value.cidr
  remote_group_id   = each.value.remote_group_id
  security_group_id = openstack_networking_secgroup_v2.this[0].id
}
