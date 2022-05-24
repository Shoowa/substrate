terraform {
  required_version = "~> 1.0"

  required_providers {

    aws         = {
      version   = ">= 4.0"
      source    = "hashicorp/aws"
    }

  }

}

provider "aws" {
    region    = "us-east-2"

    default_tags {
      tags          = {
        Environment = var.environ
        Service     = "ops"
        Dept        = "sre"
      }
    }
}
