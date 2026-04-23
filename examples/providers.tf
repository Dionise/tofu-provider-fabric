locals {
  aws_active = contains(tolist(var.clouds), "aws")
}

provider "aws" {
  region = var.aws_region

  access_key                  = local.aws_active ? null : "placeholder"
  secret_key                  = local.aws_active ? null : "placeholder"
  skip_credentials_validation = !local.aws_active
  skip_metadata_api_check     = !local.aws_active
  skip_requesting_account_id  = !local.aws_active
}

provider "openstack" {
  auth_url    = var.openstack_auth_url
  user_name   = var.openstack_user_name
  password    = var.openstack_password
  tenant_name = var.openstack_tenant_name
}
