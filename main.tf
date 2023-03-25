module "ec2" {
  for_each      = var.component
  source        = "./ec2"
  component     = each.value["name"]
  instance_type = each.value["type"]
  tags          = {
    name = each.value[var.component]
  }
}

