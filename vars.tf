variable "component" {
  default = {
    frontend = {
      name = "frontend"
      type = "t3.micro"
    }
    mongodb = {
      name = "mongodb"
      type = "t3.micro"
    }
    catalogue = {
      name = "catalogue"
      type = "t3.micro"
    }
    redis = {
      name = "redis"
      type = "t3.micro"
    }
    user = {
      name = "user"
      type = "t3.micro"
    }
  }
}