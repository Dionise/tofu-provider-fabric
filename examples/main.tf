module "network" {
  source = "../fabric/networking"

  name   = var.deployment_name
  clouds = var.clouds

  aws_network_mode = var.aws_network_mode
  aws_network      = var.aws_network

  openstack_network_mode          = var.openstack_network_mode
  openstack_network               = var.openstack_network
  openstack_external_network_name = var.openstack_external_network_name
}

module "web" {
  source = "../fabric/vm"

  name            = "web"
  clouds          = var.clouds
  image_release   = var.image_release
  image_catalog   = local.image_catalog
  machine_catalog = local.machine_profiles
  machine_profile = var.machine_profile
  ssh_key         = var.ssh_key
  tags            = merge(local.common_tags, { role = "web" })

  security_group_rules  = var.security_group_rules
  aws_extra_rules       = var.aws_extra_rules
  openstack_extra_rules = var.openstack_extra_rules

  aws_network       = module.network.aws.subnet_id
  openstack_network = module.network.openstack.network_id
}

module "public_ip" {
  source = "../fabric/public-ip"

  name                       = "web"
  clouds                     = var.clouds
  allocate                   = var.allocate_public_ip
  aws_instance_id            = module.web.aws_instance_id
  openstack_instance_id      = module.web.openstack_instance_id
  openstack_floating_ip_pool = var.openstack_external_network_name
  tags                       = merge(local.common_tags, { role = "web" })
}
