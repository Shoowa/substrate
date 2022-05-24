locals {

  azs           = data.availability_zone.current.names
  az1           = element(data.availability_zone.current.names, 0)
  az2           = element(data.availability_zone.current.names, 1)
  az3           = element(data.availability_zone.current.names, 2)

  zero_ip4      = "0.0.0.0/0"
  zero_ip6      = "::/0"
  b_class       = "10.0.0.0/16" # 65,536 addresses

  # First 3 groups each have 4,094 addresses, because /16 + 4 = /20.
  # Next six groups each have 1,022 addresses, because /16 + 6 = /22.
  # Add arguments to the cidrsubnets() function, but don't erase or replace arguments.
  ip4_subnets   = cidrsubnets(local.b_class, 4, 4, 4, 6, 6, 6, 6, 6, 6)
  ip6_subnets   = cidrsubnets(aws_vpc.ha_net.ipv6_cidr_block, 8, 8, 8)

  # End-index is excluded, so only 0, 1, 2 read in first entry.
  k8s_nodes     = slice(local.ip4_subnets, 0, 3)
  k8s_pods      = slice(local.ip6_subnets, 0, 3)
  data_subnets  = slice(local.ip4_subnets, 3, 6)
  web_subnets   = slice(local.ip4_subnets, 6, 9)

}
