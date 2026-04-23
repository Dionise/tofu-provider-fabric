output "network" {
  value = {
    aws       = module.network.aws
    openstack = module.network.openstack
  }
}

output "ips" {
  value = {
    web = {
      aws       = module.web.aws_public_ip
      openstack = module.web.openstack_public_ip
    }
  }
}
