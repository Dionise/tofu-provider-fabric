output "aws_instance_id" {
  value       = length(aws_instance.this) > 0 ? aws_instance.this[0].id : ""
  description = "AWS EC2 instance ID, or empty if AWS is not in clouds."
}

output "aws_public_ip" {
  value       = length(aws_instance.this) > 0 ? aws_instance.this[0].public_ip : ""
  description = "AWS public IP, or empty if AWS is not in clouds."
}

output "openstack_instance_id" {
  value       = length(openstack_compute_instance_v2.this) > 0 ? openstack_compute_instance_v2.this[0].id : ""
  description = "OpenStack server ID, or empty if OpenStack is not in clouds."
}

output "openstack_public_ip" {
  value       = length(openstack_compute_instance_v2.this) > 0 ? openstack_compute_instance_v2.this[0].access_ip_v4 : ""
  description = "OpenStack IP, or empty if OpenStack is not in clouds."
}
