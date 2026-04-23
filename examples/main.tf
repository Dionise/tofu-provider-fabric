module "network" {
  source = "../fabric/networking"

  name   = var.deployment_name
  clouds = var.clouds

  aws_network_mode = var.aws_network_mode
  aws_network      = var.aws_network

  openstack_network_mode        = var.openstack_network_mode
  openstack_network             = var.openstack_network
  openstack_external_network_id = var.openstack_external_network_id
}

module "web" {
  source = "../fabric/vm"

  name              = "web"
  clouds            = var.clouds
  image_release     = var.image_release
  image_catalog     = local.image_catalog
  aws_instance_type = local.web_instance.aws_instance_type
  vcpus             = local.web_instance.vcpus
  memory_gb         = local.web_instance.memory_gb
  disk_gb           = local.web_instance.disk_gb
  ssh_key           = var.ssh_key
  tags              = merge(local.common_tags, { role = "web" })

  aws_network       = module.network.aws.subnet_id
  openstack_network = module.network.openstack.network_id
}
