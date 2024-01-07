# Internet Gateway
# https://www.terraform.io/docs/providers/aws/r/internet_gateway.html
resource "aws_internet_gateway" "mail_igw" {
  vpc_id = "${aws_vpc.mail_vpc.id}"

  tags = {
    Name = "mail-igw"
  }
}