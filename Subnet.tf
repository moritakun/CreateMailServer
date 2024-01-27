# Subnet
# https://www.terraform.io/docs/providers/aws/r/subnet.html

# Public Subnets
resource "aws_subnet" "mail_public_subnet_1a" {
  # 先程作成したVPCを参照し、そのVPC内にSubnetを立てる
  vpc_id = aws_vpc.mail_vpc.id

  # Subnetを作成するAZ
  availability_zone = "ap-northeast-1a"

  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "mail-public-subnet-1a"
  }
}

resource "aws_subnet" "mail_public_subnet_1c" {
  vpc_id = aws_vpc.mail_vpc.id

  availability_zone = "ap-northeast-1c"

  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "mail-public-subnet-1c"
  }
}

# Private Subnets
resource "aws_subnet" "mail_private_subnet_1a" {
  vpc_id = aws_vpc.mail_vpc.id

  availability_zone = "ap-northeast-1a"
  cidr_block        = "10.0.10.0/24"

  tags = {
    Name = "mail-private-subnet-1a"
  }
}

resource "aws_subnet" "mail_private_subnet_1c" {
  vpc_id = aws_vpc.mail_vpc.id

  availability_zone = "ap-northeast-1c"
  cidr_block        = "10.0.20.0/24"

  tags = {
    Name = "mail-private-subnet-1c"
  }
}