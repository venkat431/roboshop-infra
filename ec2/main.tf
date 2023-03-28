#data "aws_ami" "ami" {
#  most_recent = true
#  name_regex = "Centos-8-DevOps-Practice"
#  owners = [973714476881]
#}

data "aws_caller_identity" "current" {}

data "aws_ami" "ami" {
  most_recent = true
  name_regex = "devops-ansible"
  owners = [data.aws_caller_identity.current.account_id]
}

resource "aws_spot_instance_request" "ec2" {
  ami                    = data.aws_ami.ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.sg.id]
  wait_for_fulfillment   = true

  tags                   = {
    Name = var.component

  }
}

#Provisioner resource decoupled from ec2, for better creation of instances
resource "null_resource" "provisioner" {
  provisioner "remote-exec" {

    connection {
      host     = aws_spot_instance_request.ec2.private_ip
      user     = "centos"
      password = "DevOps321"
    }
#    inline = [
#      "sudo labauto ansible"

#      "git clone https://github.com/venkat431/Roboshop-shell.git",
#      "cd Roboshop-shell",
#      "sudo bash ${var.component}.sh ${var.password}"
#    ]
  }
}
resource "aws_security_group" "sg" {
  name        = "${var.component}-${var.env}-sg"
  description = "${var.component}-${var.env}-sg"


  ingress {
    description      = "ALL"
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
  }

  tags = {
    Name = "${var.component}-${var.env}-sg"
  }
}

resource "aws_route53_record" "route53" {
  zone_id = "Z08931683BP7DV5GJ0PAA"
  name    = "${var.component}-${var.env}.devops-practice.tech"
  type    = "A"
  ttl     = 30
  records = [aws_spot_instance_request.ec2.private_ip]
}



variable "component" {}
variable "instance_type" {}
variable "env" {
  default = "dev"
}
#variable "password" {}