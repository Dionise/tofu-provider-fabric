output "aws" {
  value = {
    elastic_ip     = length(aws_eip.this) > 0 ? aws_eip.this[0].public_ip : ""
    allocation_id  = length(aws_eip.this) > 0 ? aws_eip.this[0].id : ""
    association_id = length(aws_eip.this) > 0 ? aws_eip.this[0].association_id : ""
  }
  description = "AWS public IP values for the selected allocation."
}

output "openstack" {
  value = {
    floating_ip = length(openstack_networking_floatingip_v2.this) > 0 ? openstack_networking_floatingip_v2.this[0].address : ""
    id          = length(openstack_networking_floatingip_v2.this) > 0 ? openstack_networking_floatingip_v2.this[0].id : ""
  }
  description = "OpenStack public IP values for the selected allocation."
}
