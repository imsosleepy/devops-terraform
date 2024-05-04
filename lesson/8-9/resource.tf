provider "aws" {
  
}

variable "AWS_REGION" {
  type = string
  default = "eu-west-1"
}

resource "aws_instance" "example" {
  ami = var.AWS_REGION
  instance_type = "t2.micro"
}

## 여기까지 작성하면 terraform init을 해줘야함
# │ Error: Inconsistent dependency lock file
# │
# │ The following dependency selections recorded in the lock file are inconsistent with the current configuration:
# │   - provider registry.terraform.io/hashicorp/aws: required by this configuration but no version is selected
# │
# │ To make the initial dependency selections that will initialize the dependency lock file, run:
# │   terraform init
# 요런 에러가 발생함

# variable "AWS_REGION" {
#   type = string
# }

# variable "AMIS" {
#   type = map(string)
#   default = {
#     eu-west-1 = "my ami"
#   }
# }
# 위 상태로 두고 terrafrom console에서 검색하면 원하는 결과가 나오지 않음
# > var.AMIS[var.AWS_REGION]
# (known after apply)