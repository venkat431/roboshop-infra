terraform {
  backend "s3" {
    bucket = "terraform-31"
    key    = "05-s3-state/terraform.tfstate"
    region = "us-east-1"
  }
}

module "ec2" {
  for_each      = var.component
  source        = "./ec2"
  component     = each.value["name"]
  instance_type = each.value["type"]
# password      = try(each.value["password"], "null")
}

