# EC2
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "mail_instance" {
    ami = "ami-07c589821f2b353aa" # Ubuntu Server 22.04 LTS(無料利用枠の対象)
    instance_type = "t2.micro" # (無料利用枠の対象)
    subnet_id = "${aws_subnet.mail_public_subnet_1a.id}"
    vpc_security_group_ids = [aws_security_group.mail_sg.id]
    associate_public_ip_address = true # パブリックIPを割り当てる（動的）
    key_name = "mail-key-pair"
    tags = {
        Name = "mail-instance"
    }
}