module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                   = "sample-eks"
  cluster_version                = "1.29"
  cluster_endpoint_private_access = false
  cluster_endpoint_public_access  = true

  # EKS 애드온
  cluster_addons = {
    kube-proxy = {
      addon_version = "v1.29.1-eksbuild.2"
      # https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/managing-kube-proxy.html
    }
    vpc-cni = local.vpc_cni_config
    coredns = local.coredns_config[terraform.workspace]
  }

  # 네트워크 설정
  vpc_id                   = local.vpc_id
  subnet_ids               = local.private_subnets
  control_plane_subnet_ids = local.private_subnets

  # Fargate
  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "kube-system"
        },
        {
          namespace = "default"
        }
      ]
    }
  }

  tags = {
    "karpenter.sh/discovery" = "sample-eks"
  }
}