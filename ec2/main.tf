data "aws_ami" "ami" {
  most_recent = true
  name_regex = "Centos-8-DevOps-Practice"
  owners = [973714476881]
}

resource "aws_spot_instance_request" "ec2" {
  ami           = data.aws_ami.ami.id
  instance_type = var.component["type"]
  vpc_security_group_ids = aws_security_group.allow_tls.id
  tags = {
    name = var.component["name"]
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"


  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_route53_record" "route53" {
  zone_id = "Z08931683BP7DV5GJ0PAA"
  name    = "${var.component}.devops-practice.tech"
  type    = "A"
  ttl     = 30
  records = var.component["private_ip"]
}
variable "component" {}