locals {
  name = var.project
}


# IAM role/profile (metadata)
resource "aws_iam_role" "ecs_instance_role" {
  name = "${local.name}-ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_attach" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${local.name}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

# Launch template (AMI fake)
resource "aws_launch_template" "ecs" {
  name_prefix   = "${local.name}-ecs-lt-"
  image_id      = var.mock_ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }
}

# ASG mock: capacity=0 => no instances created
resource "aws_autoscaling_group" "ecs" {
  count               = var.enable_asg ? 1 : 0
  name                = "${local.name}-ecs-asg"
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }
}

resource "aws_instance" "mock" {
  count         = var.create_ec2 ? 1 : 0
  ami           = var.mock_ami_id
  instance_type = var.ec2_instance_type

  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.base_sg_id]

  associate_public_ip_address = true

  key_name = var.key_name

  tags = {
    Name = "${local.name}-mock-ec2"
  }
}
