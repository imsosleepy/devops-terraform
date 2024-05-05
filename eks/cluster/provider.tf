terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.46.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "= 1.14.0"
    }
  }

  backend "s3" {
    bucket               = "s3-terraform-backend-sample"
    key                  = "terraform.tfstate"
    region               = "ap-northeast-2"
    workspace_key_prefix = "eks/v2/cluster"
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = "ap-northeast-2"
  profile = terraform.workspace

  # Make it faster by skipping something
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true

  default_tags {
    tags = {
      Team  = "sample"
      Stage = terraform.workspace
    }
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}