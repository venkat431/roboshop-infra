data "aws_ami" "ami" {
  most_recent = true
  name_regex = "Centos-8-DevOps-Practice"
  owners = [973714476881]
}


resource "aws_instance" "ec2" {
  ami                    = data.aws_ami.ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.sg.id]
 # wait_for_fulfillment   = true
  tags                   = {
    Name = var.component

  }
  provisioner "remote-exec" {

    connection {
      host     = self.public_ip
      user     = "centos"
      password = "DevOps321"
    }
    inline = [
      "git clone https://github.com/venkat431/Roboshop-shell.git",
      "sudo set-hostname ${var.component}",
      "cd Roboshop-shell",
      "sudo bash ${var.component}.sh"
    ]
  }

}


resource "aws_security_group" "sg" {
  name        = "${var.component}-${var.env}-sg"
  description = "Allow TLS inbound traffic"


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
  records = [aws_instance.ec2.private_ip]
}
variable "component" {}
variable "instance_type" {}
variable "env" {
  default = "dev"
}