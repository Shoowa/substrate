locals {

  account       = data.aws_caller_identity.requestor.account_id
  azs           = data.aws_availability_zones.current.names

  # We need a map and an index, so we can pair each AZ with a subnet.
  # The key is an AZ, and the value is an integer. So we can pair all 3 AZs with
  # all 3 data_subnets, all 3 web_subnets, etc using the TF for_each construct.
  map_az_index  = {for i, az in local.azs: az => i}

  zero_ip4      = "0.0.0.0/0"
  zero_ip6      = "::/0"
  b_class       = "10.0.0.0/16" # 65,536 addresses

  # Add arguments to the cidrsubnets() function, but don't erase or replace arguments.
  # End-index is excluded in SLICE(), so only 0, 1, 2 read in first entry.

  # First 3 each have 4,094 addresses, because /16 + 4 = /20
  # Next 3 each have 254 addresses, because /16 + 8 = /24
  # Next 6 each have 510 addresses, because /16 + 7 = /23
  ip4_subnets       = cidrsubnets(local.b_class, 4, 4, 4, 8, 8, 8, 7, 7, 7, 7, 7 ,7)
  k8s_nodes         = slice(local.ip4_subnets, 0, 3)
  web_subnets_4     = slice(local.ip4_subnets, 3, 6)
  data_subnets_4    = slice(local.ip4_subnets, 6, 9)
  cache_subnets_4   = slice(local.ip4_subnets, 9, 12)

  # AWS mandates /64 length IP6 addresses, and allows only 256 IP6 subnets.
  ip6_subnets       = cidrsubnets(aws_vpc.ha_net.ipv6_cidr_block, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8)
  k8s_pods          = slice(local.ip6_subnets, 0, 3)
  data_subnets_6    = slice(local.ip6_subnets, 3, 6)
  cache_subnets_6   = slice(local.ip6_subnets, 6, 9)
  public_subnets_6  = slice(local.ip6_subnets, 9, 12)

  # Default ports of AWS components
  redis_port      = 6379
  postgres_port   = 5432

  # IAM services
  flow_logs       = "delivery.logs.amazonaws.com"

  # S3 storage tiers
  ir_glacier      = "GLACIER_IR"    # $0.004   per GB per month
  flex_glacier    = "GLACIER"       # $0.0036
  deep_glacier    = "DEEP_ARCHIVE"  # $0.00099
}
