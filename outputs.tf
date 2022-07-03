output "vpc_id" {
  value = module.vpc.vpc_id
  sensitive = false
}

output "subnet_id" {
  value = element(module.vpc.public_subnets, 0)
  sensitive = false
}

output "availability_zone" {
  value = element(module.vpc.azs, 0)
  sensitive = false
}

output "instance_profile" {
  value = aws_iam_instance_profile.magic_profile.name
  sensitive = false
}

output "vpc_security_group_ids" {
  value = [module.security-group.security_group_id]
  sensitive = false
}