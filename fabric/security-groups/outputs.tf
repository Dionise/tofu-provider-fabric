output "aws" {
  value = {
    security_group_id = length(aws_security_group.this) > 0 ? aws_security_group.this[0].id : ""
  }
  description = "AWS security group outputs."
}

output "openstack" {
  value = {
    security_group_id   = length(openstack_networking_secgroup_v2.this) > 0 ? openstack_networking_secgroup_v2.this[0].id : ""
    security_group_name = length(openstack_networking_secgroup_v2.this) > 0 ? openstack_networking_secgroup_v2.this[0].name : ""
  }
  description = "OpenStack security group outputs."
}
