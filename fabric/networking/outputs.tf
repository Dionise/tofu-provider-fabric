output "aws" {
  value = {
    mode      = var.aws_network_mode
    subnet_id = length(aws_subnet.managed) > 0 ? aws_subnet.managed[0].id : (length(data.aws_subnet.existing) > 0 ? data.aws_subnet.existing[0].id : "")
    vpc_id    = length(aws_vpc.managed) > 0 ? aws_vpc.managed[0].id : (length(data.aws_subnet.existing) > 0 ? data.aws_subnet.existing[0].vpc_id : "")
  }
  description = "AWS networking values for the selected or managed topology."
}

output "openstack" {
  value = {
    mode       = var.openstack_network_mode
    network_id = length(openstack_networking_network_v2.managed) > 0 ? openstack_networking_network_v2.managed[0].id : (length(data.openstack_networking_network_v2.existing) > 0 ? data.openstack_networking_network_v2.existing[0].id : "")
    subnet_id  = length(openstack_networking_subnet_v2.managed) > 0 ? openstack_networking_subnet_v2.managed[0].id : ""
    router_id  = length(openstack_networking_router_v2.managed) > 0 ? openstack_networking_router_v2.managed[0].id : ""
  }
  description = "OpenStack networking values for the selected or managed topology."
}
