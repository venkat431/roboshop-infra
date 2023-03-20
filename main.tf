module "ec2" {
  for_each      = var.component
  source        = "./ec2"
  component     = var.component["name"]
  instance_type = var.component["type"]
}
