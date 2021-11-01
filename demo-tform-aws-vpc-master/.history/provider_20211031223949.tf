terraform {
  required_version = ">= 0.13.0"

  required_providers {
    aws = {
      region = var.region
      source  = "hashicorp/aws"
      version = ">= 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 2.0"
    }
  }
}
