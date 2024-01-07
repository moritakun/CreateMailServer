# SecurityGroup
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group#example-usage
resource "aws_security_group" "mail_sg" {
    name        = "mail_sg"
    description = "Allow TLS inbound traffic"
    vpc_id      = aws_vpc.mail_vpc.id

    # インバウンド
        ingress {
        description      = "SSH from VPC"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    # アウトバウンド
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    tags = {
        Name = "mail-sg"
    }
}