data "aws_region" "current" {}


data "aws_availability_zones" "current" {
  state = "available"
}


data "aws_caller_identity" "requestor" {}


data "aws_iam_role" "bucket_master" {
  name = var.bastion_bucket_master
}
