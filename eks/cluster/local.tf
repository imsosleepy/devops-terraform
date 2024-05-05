locals {
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnets = data.terraform_remote_state.vpc.outputs.private_subnets
}

locals {
  vpc_cni_config = {
    # https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/managing-vpc-cni.html#vpc-cni-latest-available-version
    addon_version = "v1.17.1-eksbuild.1"
    # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
    # Reference docs https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/security-groups-for-pods.html
    configuration_values = jsonencode({
      env = {
        ENABLE_POD_ENI           = "true"
        ENABLE_PREFIX_DELEGATION = "true"
        WARM_PREFIX_TARGET       = "1"
      }
      init = {
        env = {
          DISABLE_TCP_EARLY_DEMUX = "true"
        }
      }
    })
  }

  # https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/managing-coredns.html
  coredns_config = {
    testbed = {
      addon_version = "v1.11.1-eksbuild.6"
      configuration_values = jsonencode({
        computeType = "Fargate"
        resources = {
          limits = {
            cpu    = "0.25"
            memory = "256M"
          }
          requests = {
            cpu    = "0.25"
            memory = "256M"
          }
        }
      })
    }
  }
}