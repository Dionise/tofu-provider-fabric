output "network" {
  value = {
    aws       = module.network.aws
    openstack = module.network.openstack
  }
}

output "public_ip" {
  value = {
    web = {
      aws       = module.public_ip.aws
      openstack = module.public_ip.openstack
    }
  }
}
