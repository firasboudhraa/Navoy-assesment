variable "project" {
  type    = string
  default = "navoy"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "localstack_endpoint" {
  type    = string
  default = "http://localhost:4566"
}

variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.10.11.0/24", "10.10.12.0/24"]
}

# mock compute sizing => 0 instances
variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "desired_capacity" {
  type    = number
  default = 0
}

variable "min_size" {
  type    = number
  default = 0
}

variable "max_size" {
  type    = number
  default = 0
}

# fake AMI id (needed by aws_launch_template schema)
variable "mock_ami_id" {
  type    = string
  default = "ami-00000000000000000"
}


variable "create_ec2" {
  type    = bool
  default = true
}

variable "key_name" {
  type    = string
  default = null
}

variable "ec2_instance_type" {
  type    = string
  default = "t3.micro"
}
