provider "aws" {
  access_key = "YOUR ACCESS KEY"
  secret_key = "YOUR SECRET KEY"
  region = "ap-northeast-2"
}
resource "aws_instance" "test" {
  ami = "ami-0dd97ebb907cf9366"
  instance_type = "t2.micro"
}

# 디렉토리를 나누고 provider를 새로 지정할 때마다 terafform init을 해줘야함
# https://cloud-images.ubuntu.com/locator/ec2/