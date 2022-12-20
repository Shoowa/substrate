data "aws_key_pair" "bastion" {
  key_name            = local.bastion
  include_public_key  = true
}

module "bastion" {
  source    = "git@github.com:Guimove/terraform-aws-bastion.git?ref=master"

  region                  = data.aws_region.current.name
  vpc_id                  = aws_vpc.ha_net.id

  bucket_name             = local.bastion
  bucket_force_destroy    = true
  bastion_host_key_pair   = data.aws_key_pair.bastion.key_name
  bastion_iam_policy_name = local.bastion

  create_dns_record       = true
  hosted_zone_id          = aws_route53_zone.employee.zone_id
  bastion_record_name     = "door.${aws_route53_zone.employee.name}"

  is_lb_private               = false
  elb_subnets                 = values(aws_subnet.public).*.id
  auto_scaling_group_subnets  = values(aws_subnet.public).*.id

  tags = {
    name        = local.bastion
    description = "FOSS bastion."
  }
}


data "aws_iam_policy_document" "who_can_access_bastion_bucket" {
  statement {
    sid         = "CanAccessBastionBucket"
    actions     = ["s3:*"]
    effect      = "Allow"

    resources   = [
      module.bastion.bucket_arn,
      "${module.bastion.bucket_arn}/*"
     ]

     principals {
       type = "AWS"
       identifiers = [data.aws_iam_role.bucket_master.arn]
     }
  }
}


resource "aws_s3_bucket_policy" "access" {
  bucket = module.bastion.bucket_name
  policy = data.aws_iam_policy_document.who_can_access_bastion_bucket.json
}
