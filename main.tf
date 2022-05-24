resource "aws_vpc" "ha_net" {
  cidr_block = local.b_class
  assign_generated_ipv6_cidr_block  = true

  instance_tenancy      = "default" # VM shared on a host.
  enable_dns_support    = true
  enable_dns_hostnames  = false

  tags = {
    Name = "network"
  }
}


# Public subnets
resource "aws_subnet" "public1" {
  vpc_id              = aws_vpc.ha_net.id
  availability_zone   = local.az1
  cidr_block          = element(local.web_subnets, 0)

  tags = {
    Name = "public"
  }
}


resource "aws_subnet" "public2" {
  vpc_id              = aws_vpc.ha_net.id
  availability_zone   = local.az2
  cidr_block          = element(local.web_subnets, 1)

  tags = {
    Name = "public"
  }
}


resource "aws_subnet" "public3" {
  vpc_id              = aws_vpc.ha_net.id
  availability_zone   = local.az3
  cidr_block          = element(local.web_subnets, 2)

  tags = {
    Name = "public"
  }
}


# Private subnets for databases.
resource "aws_subnet" "private_data1" {
  vpc_id              = aws_vpc.ha_net.id
  availability_zone   = local.az1
  cidr_block          = element(local.data_subnets, 0)

  tags = {
    Name = "private_data"
  }
}


resource "aws_subnet" "private_data2" {
  vpc_id              = aws_vpc.ha_net.id
  availability_zone   = local.az2
  cidr_block          = element(local.data_subnets, 1)

  tags = {
    Name = "private_data"
  }
}


resource "aws_subnet" "private_data3" {
  vpc_id              = aws_vpc.ha_net.id
  availability_zone   = local.az3
  cidr_block          = element(local.data_subnets, 2)

  tags = {
    Name = "private_data"
  }
}


# Subnets for K8S hosts & pods.
resource "aws_subnet" "private_app1" {
  vpc_id              = aws_vpc.ha_net.id
  availability_zone   = local.az1
  cidr_block          = element(local.k8s_nodes, 0)
  ipv6_cidr_block     = element(local.k8s_pods, 0)

  assign_ipv6_address_on_creation = false

  tags = {
    Name = "private_app"
  }
}


resource "aws_subnet" "private_app2" {
  vpc_id              = aws_vpc.ha_net.id
  availability_zone   = local.az2
  cidr_block          = element(local.k8s_nodes, 1)
  ipv6_cidr_block     = element(local.k8s_pods, 1)

  assign_ipv6_address_on_creation = false

  tags = {
    Name = "private_app"
  }
}


resource "aws_subnet" "private_app3" {
  vpc_id              = aws_vpc.ha_net.id
  availability_zone   = local.az3
  cidr_block          = element(local.k8s_nodes, 2)
  ipv6_cidr_block     = element(local.k8s_pods, 2)

  assign_ipv6_address_on_creation = false

  tags = {
    Name = "private_app"
  }
}


# Two gateways.
resource "aws_internet_gateway" "app_gateway" {
  vpc_id              = aws_vpc.ha_net.id

  tags = {
    Name = "gateway"
  }
}


# Stateful resource, so responses arrive through this IGW.
resource "aws_egress_only_internet_gateway" "ip6_egress_gateway" {
  vpc_id              = aws_vpc.ha_net.id

  tags = {
    Name = "ip6_egress_gateway"
  }
}


# Route table created by AWS concurrently with VPC and adopted by TF afterward.
resource "aws_default_route_table" "rules" {
  default_route_table_id = aws_vpc.ha_net.default_route_table_id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = aws_internet_gateway.app_gateway
  }

  route {
    ipv6_cidr_block         = "::/0"
    egress_only_gateway_id  = aws_egress_only_internet_gateway.ip6_egress_gateway.id
  }

  tags = {
    Name = "default_route_table"
  }
}


resource "aws_route_table_association" "public" {
  subnet_id = ?
  route_table_id = ?
}


resource "aws_route_table_association" "private" {
  subnet_id = ?
  route_table_id = ?
}


# Server Firewall
resource "aws_security_group" "allow_tls" {
  vpc_id = aws_vpc.ha_net.id
  name = "allow_tls"
  description = "Allow TLS inbound traffic."

  # Rules are stateful, so a response is allowed for secure inbound requests...
  ingress {
    description       = "TLS from VPC."
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = [aws_vpc.ha_net.cidr_block]
    ipv6_cidr_blocks  = [aws_vpc.ha_net.ipv6_cidr_block]
  }

  # ... despite the fact that a server can't initiate a request to the public web.
  egress {
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = [local.zero_ip4]
    ipv6_cidr_blocks  = [local.zero_ip6]
  }
}


# Network Firewall, stateless so both ingress & egress must be defined.
resource "aws_network_acl" "secondary" {
  vpc_id = aws_vpc.ha_net.id

  ingress {
    protocol        = "tcp"
    rule_no         = 100
    action          = "allow"
    cidr_block      =
    from_port       = 
    to_ port        =
  }

  egress {
    protocol        = "tcp"
    rule_no         = 200
    action          = "allow"
    cidr_block      =
    from_port       = 443
    to_port         = 443
  }

}
