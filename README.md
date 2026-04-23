# tofu-provider-fabric

OpenTofu modules for small cross-cloud VM workflows on AWS and OpenStack.

This repo is built around a simple idea: keep one Terraform/OpenTofu shape for a machine, but do not pretend AWS and OpenStack are identical under the hood. Image selection, sizing, and networking stay explicit where they need to.

- GitLab repository: [GitLab](https://gitlab.com/moscalu.dionisie/tofu-provider-fabric)
- GitHub repository: [GitHub](https://github.com/Dionise/tofu-provider-fabric)

## What is here

- `fabric/vm` creates a VM on the clouds you enable
- `fabric/networking` either attaches to existing networking or creates a minimal managed network
- `examples/` shows a small stack split into providers, locals, variables, main, and outputs

## Current approach

- Images are selected through `image_release` and `image_catalog` — a map keyed by release name, with per-cloud image IDs
- Sizing is selected through `machine_profile` and `machine_catalog` — a map keyed by profile name, with `aws_instance_type`, `vcpus`, `memory_gb`, and `disk_gb`; the vm module resolves both internally
- Networking returns provider-shaped outputs:
  - `module.network.aws.subnet_id`
  - `module.network.aws.vpc_id`
  - `module.network.openstack.network_id`
  - `module.network.openstack.subnet_id`
  - `module.network.openstack.router_id`

## Status

Early stage. The module boundaries are in place, but inputs and outputs may still change while the layout settles.

## Requirements

- OpenTofu `>= 1.8` (cross-variable references in validation blocks)
- AWS provider `~> 5.0`
- OpenStack provider `~> 1.54`

## Quick start

The easiest place to start is the example stack.

```bash
cd examples
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars
tofu init
tofu plan
```

The example is set up to show:

- a named `image_release`
- a named `machine_profile`
- existing networking on AWS
- managed networking on OpenStack

## Example

```hcl
locals {
  image_catalog = {
    "debian-12-v2026.04" = {
      aws       = { ami_id   = "ami-0123456789abcdef0" }
      openstack = { image_id = "01234567-89ab-cdef-0123-456789abcdef" }
    }
  }

  machine_profiles = {
    small = {
      aws_instance_type = "t3.medium"
      vcpus             = 2
      memory_gb         = 4
      disk_gb           = 20
    }
  }
}

module "network" {
  source = "github.com/Dionise/tofu-provider-fabric//fabric/networking"

  name   = "example"
  clouds = ["aws", "openstack"]

  aws_network_mode = "existing"
  aws_network      = "subnet-0abc123"

  openstack_network_mode        = "managed"
  openstack_external_network_id = "ext-net-uuid-abcde"
}

module "web" {
  source = "github.com/Dionise/tofu-provider-fabric//fabric/vm"

  name             = "web"
  clouds           = ["aws", "openstack"]
  image_release    = "debian-12-v2026.04"
  image_catalog    = local.image_catalog
  machine_profile  = "small"
  machine_catalog  = local.machine_profiles
  ssh_key          = "my-key"
  tags             = { env = "prod", role = "web" }

  aws_network       = module.network.aws.subnet_id
  openstack_network = module.network.openstack.network_id
}
```

## Modules

### `fabric/vm`

This module creates the VM resources.

What you pass in:

- `clouds`
- `image_release` and `image_catalog` — the module resolves the right image per cloud
- `machine_profile` and `machine_catalog` — the module resolves instance type, vCPUs, memory, and disk
- provider-specific network attachment IDs

What it returns:

- AWS instance ID and public IP
- OpenStack instance ID and public IP

### `fabric/networking`

This module is intentionally narrow. It is not trying to be a full generic networking framework.

It supports two modes per cloud:

- use an existing AWS subnet or OpenStack network
- create a minimal managed topology for that cloud

Managed mode currently means:

- AWS: VPC, subnet, internet gateway, route table, route table association
- OpenStack: network, subnet, and optional router when an external network is provided

## CI

GitLab CI runs a small verification pipeline:

- `tofu fmt -check -recursive`
- `tofu init -backend=false`
- `tofu validate`

The pipeline checks `fabric/vm`, `fabric/networking`, and `examples`.

## What this repo is not trying to do

- hide every provider difference behind one fake abstraction
- auto-discover "latest" images at apply time
- act as a full networking platform for every topology

## Contributing

Issues and pull requests are welcome. If you change the module interface, update the example stack and README in the same change.

## License

This project is licensed under the Mozilla Public License 2.0. See [LICENSE](LICENSE).
