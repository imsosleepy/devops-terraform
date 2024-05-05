data "terraform_remote_state" "vpc" {
  backend   = "s3"
  workspace = terraform.workspace

  config = {
    bucket               = "s3-terraform-backend-sample"
    key                  = "terraform.tfstate"
    region               = "ap-northeast-2"
    workspace_key_prefix = "vpc/ap-northeast-2"
  }
}