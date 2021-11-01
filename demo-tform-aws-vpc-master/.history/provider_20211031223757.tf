provider "aws" {
  region = var.region
  profile  = "Tanvinder"
  source  = "hashicorp/aws"
  version = ">= 2.0"
}