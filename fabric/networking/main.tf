locals {
  use_aws            = contains(tolist(var.clouds), "aws")
  use_openstack      = contains(tolist(var.clouds), "openstack")
  use_existing_aws   = local.use_aws && var.aws_network_mode == "existing"
  use_managed_aws    = local.use_aws && var.aws_network_mode == "managed"
  use_existing_os    = local.use_openstack && var.openstack_network_mode == "existing"
  use_managed_os     = local.use_openstack && var.openstack_network_mode == "managed"
  use_openstack_edge = local.use_managed_os && var.openstack_external_network_id != ""
}

data "aws_subnet" "existing" {
  count = local.use_existing_aws ? 1 : 0
  id    = var.aws_network
}

resource "aws_vpc" "managed" {
  count                = local.use_managed_aws ? 1 : 0
  cidr_block           = var.aws_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name}-vpc"
  }
}

resource "aws_subnet" "managed" {
  count                   = local.use_managed_aws ? 1 : 0
  vpc_id                  = aws_vpc.managed[0].id
  cidr_block              = var.aws_subnet_cidr
  availability_zone       = var.aws_availability_zone != "" ? var.aws_availability_zone : null
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-subnet"
  }
}

resource "aws_internet_gateway" "managed" {
  count  = local.use_managed_aws ? 1 : 0
  vpc_id = aws_vpc.managed[0].id

  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_route_table" "managed" {
  count  = local.use_managed_aws ? 1 : 0
  vpc_id = aws_vpc.managed[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.managed[0].id
  }

  tags = {
    Name = "${var.name}-rt"
  }
}

resource "aws_route_table_association" "managed" {
  count          = local.use_managed_aws ? 1 : 0
  subnet_id      = aws_subnet.managed[0].id
  route_table_id = aws_route_table.managed[0].id
}

data "openstack_networking_network_v2" "existing" {
  count      = local.use_existing_os ? 1 : 0
  network_id = var.openstack_network
}

resource "openstack_networking_network_v2" "managed" {
  count          = local.use_managed_os ? 1 : 0
  name           = "${var.name}-network"
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "managed" {
  count           = local.use_managed_os ? 1 : 0
  name            = "${var.name}-subnet"
  network_id      = openstack_networking_network_v2.managed[0].id
  cidr            = var.openstack_subnet_cidr
  ip_version      = 4
  enable_dhcp     = var.openstack_enable_dhcp
  dns_nameservers = var.openstack_dns_nameservers
}

resource "openstack_networking_router_v2" "managed" {
  count               = local.use_openstack_edge ? 1 : 0
  name                = "${var.name}-router"
  external_network_id = var.openstack_external_network_id
}

resource "openstack_networking_router_interface_v2" "managed" {
  count     = local.use_openstack_edge ? 1 : 0
  router_id = openstack_networking_router_v2.managed[0].id
  subnet_id = openstack_networking_subnet_v2.managed[0].id
}
