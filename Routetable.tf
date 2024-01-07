# RouteTable
# 経路情報の格納
# https://www.terraform.io/docs/providers/aws/r/route_table.html
resource "aws_route_table" "mail_public_route_table" {
    vpc_id = "${aws_vpc.mail_vpc.id}"
    tags = {
        Name = "mail-public-route-table"
    }
}

# Route
# Route Tableへ経路情報を追加
# インターネット(0.0.0.0/0)へ接続する際はInternet Gatewayを使用するように設定する
# https://www.terraform.io/docs/providers/aws/r/route.html
resource "aws_route" "mail_public_route" {
destination_cidr_block = "0.0.0.0/0"
route_table_id         = "${aws_route_table.mail_public_route_table.id}"
gateway_id             = "${aws_internet_gateway.mail_igw.id}"
}

# Association（関連）
# Route TableとSubnetの紐づけ
# https://www.terraform.io/docs/providers/aws/r/route_table_association.html
resource "aws_route_table_association" "mail_association_public_1a" {
subnet_id      = "${aws_subnet.mail_public_subnet_1a.id}"
route_table_id = "${aws_route_table.mail_public_route_table.id}"
}

resource "aws_route_table_association" "mail_association_public_1c" {
subnet_id      = "${aws_subnet.mail_public_subnet_1c.id}"
route_table_id = "${aws_route_table.mail_public_route_table.id}"
}