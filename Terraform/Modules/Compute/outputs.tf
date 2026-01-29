output "launch_template_name"   { value = aws_launch_template.ecs.name }
output "asg_name" {
  value = try(aws_autoscaling_group.ecs[0].name, null)
}
output "instance_profile_name"  { value = aws_iam_instance_profile.ecs_instance_profile.name }
output "iam_role_name"          { value = aws_iam_role.ecs_instance_role.name }
output "ec2_instance_id" {
  value = try(aws_instance.mock[0].id, null)
}
