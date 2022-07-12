data "aws_region" "current" {}


data "aws_availability_zones" "current" {
  state = "available"
}


data "aws_caller_identity" "requestor" {}
