# SecurityGroup
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group#example-usage
# Public Security Group
resource "aws_security_group" "mail_pub_sg" {
  name        = "mail_pub_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.mail_vpc.id

  # インバウンド
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # アウトバウンド
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mail-pub-sg"
  }
}

# Private Security Group
resource "aws_security_group" "mail_pri_sg" {
  name        = "mail_pri_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.mail_vpc.id

  # インバウンド
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.mail_public_subnet_1a.cidr_block]
  }
  ingress {
    description = "IMAP from VPC"
    from_port   = 143
    to_port     = 143
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.mail_public_subnet_1a.cidr_block]
  }
  ingress {
    description = "POP3 from VPC"
    from_port   = 110
    to_port     = 110
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.mail_public_subnet_1a.cidr_block]
  }
  ingress {
    description = "CustomTCP from VPC"
    from_port   = 587
    to_port     = 587
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.mail_public_subnet_1a.cidr_block]
  }
  ingress {
    description = "SMTP from VPC"
    from_port   = 25
    to_port     = 25
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.mail_public_subnet_1a.cidr_block]
  }
  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.mail_public_subnet_1a.cidr_block]
  }

  # アウトバウンド
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mail-pri-sg"
  }
}