#  Creating Spot instances for Roboshop
resource "aws_spot_instance_request" "ec2" {
  ami                    = data.aws_ami.ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.sg.id]
  wait_for_fulfillment   = true
  iam_instance_profile = "${var.env}-${var.component}-role"

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
    inline = [
       "sudo set-hostname -skip-apply ${var.component}",
      "ansible-pull -i localhost -U https://github.com/venkat431/roboshop-ansible roboshop.yml -e role_name=${var.component} -e env=${var.env}"

#      "sudo labauto ansible"
#      "git clone https://github.com/venkat431/Roboshop-shell.git",
#      "cd Roboshop-shell",
#      "sudo bash ${var.component}.sh ${var.password}"
    ]
  }
}

# creating sg resources for all instances
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

# Individual route53 records for all instances
resource "aws_route53_record" "route53" {
  zone_id = "Z08931683BP7DV5GJ0PAA"
  name    = "${var.component}-${var.env}.devops-practice.tech"
  type    = "A"
  ttl     = 30
  records = [aws_spot_instance_request.ec2.private_ip]
}

# Creating IAM policy
resource "aws_iam_policy" "ssm-policy" {
  name        = "${var.env}-${var.component}-ssm"
  path        = "/"
  description = "${var.env}-${var.component}-ssm"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": [
          "ssm:GetParameterHistory",
          "ssm:GetParametersByPath",
          "ssm:GetParameters",
          "ssm:GetParameter"
        ],
        "Resource": "arn:aws:ssm:us-east-1:496431305037:parameter/${var.env}.${var.component}.*"
      },
      {
        "Sid": "VisualEditor1",
        "Effect": "Allow",
        "Action": "ssm:DescribeParameters",
        "Resource": "*"
      }
    ]
  })
}

# to create IAM role
resource "aws_iam_role" "role" {
  name = "${var.env}-${var.component}-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

# IAM instance profile
resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.env}-${var.component}-role"
  role = aws_iam_role.role.name
}

# IAM role policy attachment
resource "aws_iam_role_policy_attachment" "policy-attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.ssm-policy.arn
}