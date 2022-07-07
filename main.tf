resource "aws_vpc" "ha_net" {
  cidr_block = local.b_class

  # Both enabled to permit nodes to register with an EKS cluster.
  enable_dns_support    = true
  enable_dns_hostnames  = true

  instance_tenancy      = "default" # VM shared on a host.

  assign_generated_ipv6_cidr_block  = true

  tags = {
    Name = "network"
  }
}


# Public subnets
resource "aws_subnet" "public" {
  for_each            = local.map_az_index

  vpc_id              = aws_vpc.ha_net.id
  availability_zone   = each.key
  cidr_block          = element(local.web_subnets, each.value)
  ipv6_cidr_block     = element(local.public_subnets_6, each.value)

  tags = {
    Name = "public-${each.key}"
    ip   = "dual"
    "kubernetes.io/role/elb" = 1
  }
}


# Subnets for K8S hosts & pods.
resource "aws_subnet" "private_app" {
  for_each            = local.map_az_index

  vpc_id              = aws_vpc.ha_net.id
  availability_zone   = each.key
  cidr_block          = element(local.k8s_nodes, each.value)
  ipv6_cidr_block     = element(local.k8s_pods, each.value)

  assign_ipv6_address_on_creation                 = true
  enable_resource_name_dns_aaaa_record_on_launch  = true

  tags = {
    Name  = "app-${each.key}"
    ip    = "dual"
  }
}


# Private subnets for databases.
resource "aws_subnet" "private_data" {
  for_each            = local.map_az_index

  vpc_id              = aws_vpc.ha_net.id
  availability_zone   = each.key
  ipv6_cidr_block     = element(local.data_subnets_6, each.value)
  ipv6_native         = true

  assign_ipv6_address_on_creation                 = true
  enable_resource_name_dns_aaaa_record_on_launch  = true

  tags = {
    Name  = "data-${each.key}"
    ip    = "6"
  }
}


# Private subnets for caches.
resource "aws_subnet" "private_cache" {
  for_each            = local.map_az_index

  vpc_id              = aws_vpc.ha_net.id
  availability_zone   = each.key
  ipv6_cidr_block     = element(local.cache_subnets_6, each.value)
  ipv6_native         = true

  assign_ipv6_address_on_creation = true

  tags = {
    Name = "cache-${each.key}"
    ip   = "6"
  }
}


resource "aws_db_subnet_group" "private_data" {
  name          = "private-data"
  description   = "Separate set of subnets for PostgreSQL."
  subnet_ids    = values(aws_subnet.private_data).*.id

  depends_on    = [aws_subnet.private_data]
}


resource "aws_elasticache_subnet_group" "private_cache" {
  name          = "private-cache"
  description   = "Separate set of subnets for Redis and Memcache."
  subnet_ids    = values(aws_subnet.private_cache).*.id


  depends_on    = [aws_subnet.private_cache]
}


# Stateful resource, so responses arrive through this GW.
resource "aws_egress_only_internet_gateway" "ip6_egress_gateway" {
  vpc_id              = aws_vpc.ha_net.id

  tags = {
    Name = "gateway"
    ip   = "6"
  }
}


# Route table created by AWS concurrently with VPC and adopted by TF afterward.
# Later, the IPv6 route is added.
resource "aws_default_route_table" "rules" {
  default_route_table_id = aws_vpc.ha_net.default_route_table_id

  route {
    ipv6_cidr_block         = local.zero_ip6
    egress_only_gateway_id  = aws_egress_only_internet_gateway.ip6_egress_gateway.id
  }

  tags = {
    Name = "default_route_table"
  }
}


# Exclusively for IP4-originating requests, each private subnet needs to be directed
# toward its own AZ's NAT Gateway residing in a public subnet.
# All private subnets will use the same EOGW for IP6.
resource "aws_route_table" "private_app" {
  for_each  = toset(local.azs)

  vpc_id    = aws_vpc.ha_net.id

  route {
    ipv6_cidr_block         = local.zero_ip6
    egress_only_gateway_id  = aws_egress_only_internet_gateway.ip6_egress_gateway.id
  }

  route {
    cidr_block              = local.zero_ip4
    nat_gateway_id          = aws_nat_gateway.ec2_to_igw[each.key].id
  }

  tags = {
    Name = "private-app-${each.key}"
    type = "private-app"
  }

  depends_on = [aws_nat_gateway.ec2_to_igw]
}


resource "aws_route_table_association" "private_app" {
  for_each          = toset(local.azs)

  route_table_id    = aws_route_table.private_app[each.key].id
  subnet_id         = aws_subnet.private_app[each.key].id

  depends_on = [
    aws_subnet.private_app,
    aws_route_table.private_app
  ]
}
