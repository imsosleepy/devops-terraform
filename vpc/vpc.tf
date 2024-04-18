locals {
  polarishare = {
    tag = {
      Service = local.service
      Stage = local.stage
    }
  }
  service         = "polarishare"
  vpc_name        = "testbed-polarishare"
  stage           = "testbed"
  cidr            = "10.0.0.0/16"
  public_subnets  = ["10.0.0.0/22", "10.0.4.0/22"]
  private_subnets = ["10.0.16.0/20", "10.0.32.0/20"]
  azs             = ["ap-northeast-2a", "ap-northeast-2c"]
  cluster_name    = "eks-testbed"
  
}

provider "aws" {
  region = "ap-northeast-2"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.vpc_name
  cidr = local.cidr

  azs             = local.azs
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets

#   enable_nat_gateway     = true
#   one_nat_gateway_per_az = true
  single_nat_gateway   = true
  enable_dns_support   = true
  enable_dns_hostnames = false

  create_database_subnet_group = false

  igw_tags = {
    Name = "testbed-polarishare-intertnet"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "karpenter.sh/discovery" : "ps-eks-${terraform.workspace}"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  tags = local.polarishare.tag
}