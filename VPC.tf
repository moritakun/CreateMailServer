# VPC
# https://www.terraform.io/docs/providers/aws/r/vpc.html
resource "aws_vpc" "mail_vpc" {
    cidr_block = "10.0.0.0/16"  # VPCのCIDRブロックを指定します
    tags={
        Name = "mail-vpc"  # VPCの名前を指定します
    }
}