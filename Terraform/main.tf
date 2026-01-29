module "network" {
  source          = "./Modules/Network"
  project         = var.project
  region          = var.region
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "compute" {
  source   = "./Modules/Compute"
  project  = var.project
  region   = var.region

  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  public_subnet_id = module.network.public_subnet_ids[0]
  base_sg_id       = module.network.base_sg_id

  instance_type    = var.instance_type
  desired_capacity = var.desired_capacity
  min_size         = var.min_size
  max_size         = var.max_size
  mock_ami_id      = var.mock_ami_id

  create_ec2        = var.create_ec2
  ec2_instance_type = var.ec2_instance_type
  key_name          = var.key_name

  enable_asg = false
}

