terraform {
  required_version = ">= 0.13.0"

  required_providers {
    aws = {
      region = var.region
    }
  }
}
