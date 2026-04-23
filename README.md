# fabric

OpenTofu modules for launching the same VM definition on AWS, OpenStack, or both.

```hcl
locals {
  image_catalog = {
    "debian-12-v2026.04" = {
      aws = {
        ami_id = "ami-0123456789abcdef0"
      }
      openstack = {
        image_id = "01234567-89ab-cdef-0123-456789abcdef"
      }
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

  web_instance = local.machine_profiles["small"]
}

module "web" {
  source = "github.com/dionisiemoscalu/tofu-provider-fabric//fabric/vm"

  name              = "web"
  clouds            = ["aws", "openstack"]
  image_release     = "debian-12-v2026.04"
  image_catalog     = local.image_catalog
  aws_instance_type = local.web_instance.aws_instance_type
  vcpus             = local.web_instance.vcpus
  memory_gb         = local.web_instance.memory_gb
  disk_gb           = local.web_instance.disk_gb
  ssh_key           = "my-key"
  tags              = { env = "prod" }

  aws_network       = "subnet-0abc123"
  openstack_network = "net-uuid-abcde"
}
```

Use the same module inputs whether you are targeting one cloud or several. The image choice now comes from a named release instead of provider-specific lookup rules.

## Modules

### `fabric/vm`

Creates a VM on the clouds listed in `clouds`.

| Variable | Description | Default |
| --- | --- | --- |
| `name` | Instance name | `"vm"` |
| `clouds` | `["aws"]`, `["openstack"]`, or both | `[]` |
| `image_release` | Release name from `image_catalog` | `""` |
| `image_catalog` | Map of release names to AWS/OpenStack image IDs | `{}` |
| `aws_instance_type` | AWS instance type such as `t3.medium` | `""` |
| `vcpus` | CPU count | `2` |
| `memory_gb` | Memory in GB | `4` |
| `disk_gb` | Root disk size in GB | `20` |
| `ssh_key` | Existing key pair name | `""` |
| `tags` | Resource tags or metadata | `{}` |
| `aws_network` | AWS subnet ID | `""` |
| `openstack_network` | OpenStack network UUID | `""` |

### `fabric/networking`

Handles the network attachment point for each cloud and returns provider-specific objects.

It supports both patterns:

- Attach to an existing AWS subnet or OpenStack network.
- Create a minimal managed network for the cloud and return the IDs the VM module needs.
- Consume provider-specific outputs such as `module.network.aws.subnet_id` and `module.network.openstack.network_id`.

Example:

```hcl
module "network" {
  source = "github.com/dionisiemoscalu/tofu-provider-fabric//fabric/networking"

  name   = "example"
  clouds = ["aws", "openstack"]

  aws_network_mode = "existing"
  aws_network      = "subnet-0abc123"

  openstack_network_mode        = "managed"
  openstack_external_network_id = "ext-net-uuid-abcde"
}

module "web" {
  source = "github.com/dionisiemoscalu/tofu-provider-fabric//fabric/vm"

  name              = "web"
  clouds            = ["aws", "openstack"]
  image_release     = "debian-12-v2026.04"
  image_catalog     = local.image_catalog
  aws_instance_type = local.web_instance.aws_instance_type
  vcpus             = local.web_instance.vcpus
  memory_gb         = local.web_instance.memory_gb
  disk_gb           = local.web_instance.disk_gb

  aws_network       = module.network.aws.subnet_id
  openstack_network = module.network.openstack.network_id
}
```

## Notes

- The module deploys from a named image release, not from a provider-side "latest image" search.
- Each release maps to exact cloud-specific artifacts such as an AWS AMI ID and an OpenStack image ID.
- `aws_instance_type` is explicit, while `vcpus` and `memory_gb` are used for OpenStack flavor lookup.
- Both modules default to a no-op shape until you enable clouds and provide the matching inputs.
- The modules use the AWS and OpenStack providers directly.
- The example stack chooses a named `machine_profile` and resolves that into cloud-specific sizing in `locals`.
- The networking module returns structured provider outputs instead of flattening AWS and OpenStack into one shape.
- The `examples/` directory keeps providers, locals, variables, and outputs separate, while the actual deployment flow stays together in one file.

## Requirements

- OpenTofu >= 1.6
- AWS provider ~> 5.0
- OpenStack provider ~> 1.54

## Adding another cloud

Follow the same pattern used in `fabric/vm/main.tf`: gate the new data sources and resources on whether that cloud is present in `var.clouds`.
