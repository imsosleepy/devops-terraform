locals {
  sample = {
    vpc_name = "sample"
    vpc_cidr = {
      prod   = "10.1.0.0/16"
      testbed = "172.18.0.0/16"
    }
    tag = {
      Service = "sample"
    }
  }
  sample_subnet = cidrsubnets(
    local.sample.vpc_cidr[terraform.workspace],
    6, 6, 6, 6, 4, 4
  )
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.sample.vpc_name
  cidr = local.sample.vpc_cidr[terraform.workspace]

  azs = ["ap-northeast-2a", "ap-northeast-2c"]

  public_subnets   = slice(local.sample_subnet, 0, 2)
  database_subnets = slice(local.sample_subnet, 2, 4)
  private_subnets  = slice(local.sample_subnet, 4, 6)

  enable_nat_gateway      = true
  single_nat_gateway      = true
  enable_dns_hostnames    = true
  map_public_ip_on_launch = true

  create_database_subnet_group = false

  igw_tags = {
    Name = "sample-internet-gateway"
  }

  nat_gateway_tags = {
    Name = "sample-nat-gateway"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "karpenter.sh/discovery" : "eks-${terraform.workspace}"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  tags = local.sample.tag
}

resource "aws_vpc_endpoint" "sample_s3" {
  vpc_id          = module.vpc.vpc_id
  route_table_ids = module.vpc.private_route_table_ids
  service_name    = "com.amazonaws.${data.aws_region.current.name}.s3"
  tags = merge(local.sample.tag, {
    Name = "s3-gateway-${data.aws_region.current.name}"
  })
}

resource "aws_vpc_endpoint" "sample_dynamo" {
  vpc_id          = module.vpc.vpc_id
  route_table_ids = module.vpc.private_route_table_ids
  service_name    = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  tags = merge(local.sample.tag, {
    Name = "dynamodb-gateway-${data.aws_region.current.name}"
  })
}

resource "aws_db_subnet_group" "sample_rds_private" {
  name        = "${local.sample.vpc_name}-private"
  description = "${local.sample.vpc_name} subnet group - private"
  subnet_ids  = module.vpc.database_subnets
  tags        = local.sample.tag
}

resource "aws_db_subnet_group" "sample_rds_public" {
  name        = "${local.sample.vpc_name}-public"
  description = "${local.sample.vpc_name} subnet group - public"
  subnet_ids  = module.vpc.public_subnets
  tags        = local.sample.tag
}

resource "aws_elasticache_subnet_group" "sample_elasticache_private" {
  name        = "${local.sample.vpc_name}-private"
  description = "${local.sample.vpc_name} subnet group - private"
  subnet_ids  = module.vpc.database_subnets
  tags        = local.sample.tag
}