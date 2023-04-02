module "ec2" {
  for_each      = var.component
  source        = "./ec2"
  component     = each.value["name"]
  instance_type = each.value["type"]
  env           = var.env
  # password      = try(each.value["password"], "null")
}

