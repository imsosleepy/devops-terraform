locals {
  service         = "myEKS"
  vpc_name        = "test-myEKS"
  stage           = "test"
  cidr            = "10.0.0.0/16"
  public_subnets  = ["10.0.0.0/22", "10.0.4.0/22"]
  private_subnets = ["10.0.16.0/20", "10.0.32.0/20"]
  azs             = ["ap-northeast-2a", "ap-northeast-2c"]
  cluster_name    = "eks-test"
}

provider "aws" {
  region = "ap-northeast-2"
}


resource "aws_vpc" "testbed_vpc" {
  cidr_block           = local.cidr
  enable_dns_support   = true
  enable_dns_hostnames = false

  tags = {
    Name    = local.vpc_name
    Service = local.service
    Stage = local.stage
  }
}

resource "aws_subnet" "private_subnet" {
    count = length(local.private_subnets)
    
    vpc_id = aws_vpc.testbed_vpc.id
    cidr_block = local.private_subnets[count.index]
    
    availability_zone = local.azs[count.index]
    

    tags = {
      Name    = "${local.vpc_name}-private-${local.azs[count.index]}",
      Service = local.service,
      Stage = local.stage,
      "kubernetes.io/cluster/${local.cluster_name}" = "shared",
      "kubernetes.io/role/internal-elb"             = "1"
  }
}

resource "aws_subnet" "public_subnet" {
    count = length(local.public_subnets)
    
    vpc_id = aws_vpc.testbed_vpc.id
    cidr_block = local.public_subnets[count.index]
    availability_zone = local.azs[count.index]
    map_public_ip_on_launch = true

    tags = {
      Name    = "${local.vpc_name}-public-${local.azs[count.index]}"
      Service = local.service
      Stage = local.stage,
      "kubernetes.io/cluster/${local.cluster_name}" = "shared",
      "kubernetes.io/role/elb"             = "1"
  }

}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.testbed_vpc.id

  route = []

  tags = {
    Name = "${local.vpc_name}-private"
    Service = local.service
    Stage = local.stage
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.testbed_vpc.id
  tags = {
    Name = "${local.vpc_name}-public"
    Service = local.service
    Stage = local.stage
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.testbed_vpc.id

  tags = {
    Name    = "${local.vpc_name}-intertnet"
    Service = local.service
    Stage = local.stage
  }
}

resource "aws_route_table_association" "public" {
  count = length(local.public_subnets)

  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private" {
  count = length(local.private_subnets)

  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

## NAT 게이트웨이는 고정 IP를 필요로 합니다
## NAT 게이트웨이는 열어두기만 해도 비용이 나가서 주석처리
# resource "aws_eip" "nat_gateway" {
#   domain   = "vpc"
#   tags = { 
#     Name = "${local.vpc_name}-natgw" 
#     Service = local.service
#     Stage = local.stage}
# }

# ## 프라이빗 서브넷에서 인터넷 접속시 사용할 NAT 게이트웨이
# resource "aws_nat_gateway" "this" {
#   allocation_id = aws_eip.nat_gateway.id
#   subnet_id     = aws_subnet.public_subnet[0].id # NAT 게이트웨이 자체는 퍼플릭 서브넷에 위치해야 합니다
#   tags          = { Name = "${local.vpc_name}-natgw" }
# }