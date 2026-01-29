output "vpc_id"             { value = module.network.vpc_id }
output "public_subnet_ids"  { value = module.network.public_subnet_ids }
output "private_subnet_ids" { value = module.network.private_subnet_ids }

output "launch_template"  { value = module.compute.launch_template_name }
output "asg_name" {
  value = module.compute.asg_name
}
output "notes" {
  value = "LocalStack mock infra: VPC/Subnets/Routes/SG + IAM role/profile + LaunchTemplate + EC2 instance. ECS/ASG/ALB not available in this LocalStack."
}


output "ec2_instance_id" {
  value = module.compute.ec2_instance_id
}
