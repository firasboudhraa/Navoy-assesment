variable "project" { type = string }
variable "region"  { type = string }

variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }

variable "instance_type" { type = string }
variable "desired_capacity" { type = number }
variable "min_size" { type = number }
variable "max_size" { type = number }

variable "mock_ami_id" { type = string }

variable "public_subnet_id" { type = string }
variable "base_sg_id"       { type = string }

variable "create_ec2" {
  type    = bool
  default = true
}

variable "ec2_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type    = string
  default = null
}

variable "enable_asg" {
  type    = bool
  default = false
}

