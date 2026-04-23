# tofu-provider-fabric

OpenTofu modules for deploying VMs on AWS and OpenStack without pretending the two clouds are the same.

- GitLab: https://gitlab.com/moscalu.dionisie/tofu-provider-fabric
- GitHub: https://github.com/Dionise/tofu-provider-fabric

## Modules

**`fabric/vm`** — creates a VM on one or both clouds. Handles image selection, sizing, and security groups internally. Call it once, it does the right thing per cloud.

**`fabric/security-groups`** — creates and manages security groups. Used internally by `fabric/vm`, but can also be called standalone when you need a shared group across multiple VMs.

**`fabric/networking`** — attaches to existing network infrastructure or creates a minimal one (VPC + subnet + IGW on AWS, network + subnet + router on OpenStack).

**`fabric/public-ip`** — allocates a stable public IP (Elastic IP on AWS, floating IP on OpenStack) and attaches it to an instance.

## Requirements

- OpenTofu >= 1.8
- AWS provider ~> 5.0
- OpenStack provider ~> 1.54

## Usage

```hcl
module "network" {
  source = "github.com/Dionise/tofu-provider-fabric//fabric/networking"

  name   = "prod"
  clouds = ["aws", "openstack"]

  aws_network_mode = "existing"
  aws_network      = "subnet-0abc123"

  openstack_network_mode          = "managed"
  openstack_external_network_name = "Admin"
}

module "web" {
  source = "github.com/Dionise/tofu-provider-fabric//fabric/vm"

  name   = "web"
  clouds = ["aws", "openstack"]

  image_release   = "debian-12-generic-amd64-20250210-2019"
  image_catalog   = local.image_catalog
  machine_profile = "small"
  machine_catalog = local.machine_profiles

  security_group_rules = [
    { direction = "ingress", protocol = "tcp", port_min = 22,  port_max = 22,  cidr = "0.0.0.0/0" },
    { direction = "ingress", protocol = "icmp", cidr = "0.0.0.0/0" },
    { direction = "egress",  protocol = "-1",   cidr = "0.0.0.0/0" },
  ]

  aws_network       = module.network.aws.subnet_id
  openstack_network = module.network.openstack.network_id
}
```

Security group rules in `security_group_rules` apply to both clouds from one list. For anything cloud-specific (IPv6, SG-to-SG on AWS, remote groups on OpenStack) there are escape hatches:

```hcl
aws_extra_rules = [
  { direction = "ingress", protocol = "tcp", port_min = 443, port_max = 443, cidr_ipv6 = "::/0" },
]

openstack_extra_rules = [
  { direction = "ingress", protocol = "tcp", port_min = 8080, port_max = 8080, remote_group_id = "uuid" },
]
```

Image and machine catalogs are maps you define and pass in — the modules do not have opinions about what images or sizes exist in your environment:

```hcl
locals {
  image_catalog = {
    "debian-12-generic-amd64-20250210-2019" = {
      aws       = { ami_id   = "ami-0abc123" }
      openstack = { image_id = "3b64d4a7-8530-4a39-9c23-81dae1d5075d" }
    }
  }

  machine_profiles = {
    small  = { aws_instance_type = "t3.medium", vcpus = 2, memory_gb = 4,  disk_gb = 20 }
    medium = { aws_instance_type = "m5.large",  vcpus = 4, memory_gb = 8,  disk_gb = 40 }
    large  = { aws_instance_type = "m5.xlarge", vcpus = 8, memory_gb = 16, disk_gb = 80 }
  }
}
```

## CI

Runs `tofu fmt -check`, `tofu init`, and `tofu validate` across all modules and the example stack.

## License

Mozilla Public License 2.0 — see [LICENSE](LICENSE).
