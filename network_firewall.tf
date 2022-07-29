# NACLs are Stateless, so both ingress & egress must be defined.
# AWS also adds a rule that denies a packet when it doesn't match any of the numbered rules.
# Many Linux kernels use ports 32768-61000.
resource "aws_network_acl" "private_data" {
  vpc_id              = aws_vpc.ha_net.id
  subnet_ids          = values(aws_subnet.private_data).*.id

  # Postgres
  ingress {
    protocol          = "tcp"
    rule_no           = 10
    action            = "allow"
    ipv6_cidr_block   = element(local.k8s_pods, 0)
    from_port         = local.postgres_port
    to_port           = local.postgres_port
  }

  # Allow response destined for K8S Pods.
  egress {
    protocol          = "tcp"
    rule_no           = 20
    action            = "allow"
    ipv6_cidr_block   = element(local.k8s_pods, 0)
    from_port         = local.postgres_port
    to_port           = local.postgres_port
  }

  # Postgres
  ingress {
    protocol          = "tcp"
    rule_no           = 11
    action            = "allow"
    ipv6_cidr_block   = element(local.k8s_pods, 1)
    from_port         = local.postgres_port
    to_port           = local.postgres_port
  }

  # Allow response destined for K8S Pods.
  egress {
    protocol          = "tcp"
    rule_no           = 21
    action            = "allow"
    ipv6_cidr_block   = element(local.k8s_pods, 1)
    from_port         = local.postgres_port
    to_port           = local.postgres_port
  }


  # Postgres
  ingress {
    protocol          = "tcp"
    rule_no           = 12
    action            = "allow"
    ipv6_cidr_block   = element(local.k8s_pods, 2)
    from_port         = local.postgres_port
    to_port           = local.postgres_port
  }

  # Allow response destined for K8S Pods.
  egress {
    protocol          = "tcp"
    rule_no           = 22
    action            = "allow"
    ipv6_cidr_block   = element(local.k8s_pods, 2)
    from_port         = local.postgres_port
    to_port           = local.postgres_port
  }


  # Lambda ports
  ingress {
    protocol          = "tcp"
    rule_no           = 100
    action            = "allow"
    cidr_block        = local.zero_ip4
    from_port         = 1024
    to_port           = 65535
  }

  # VPC Endpoint
  egress {
    protocol          = "tcp"
    rule_no           = 200
    action            = "allow"
    cidr_block        = local.zero_ip4
    from_port         = 443
    to_port           = 443
  }

  tags                = {
    Name              = "private-data"
  }

  # This resource truly depends on the VPC creating an IP6 CIDR Block,
  # and the two listed dependencies serve as adequate proxies for that attribute.
  depends_on          = [
    aws_subnet.private_data,
    aws_subnet.private_app
  ]
}


# NACL of Private App receives requests from Public Subnets,
# and delivers requests to Private Data & Private Cache.
resource "aws_network_acl" "private_app" {
  vpc_id              = aws_vpc.ha_net.id
  subnet_ids          = values(aws_subnet.private_app).*.id


  # Requests from IP6 LB
  ingress {
    protocol          = "tcp"
    rule_no           = 10
    action            = "allow"
    ipv6_cidr_block   = element(local.public_subnets_6, 0)
    from_port         = 1024
    to_port           = 65535
  }

  # Responses to IP6 LB
  egress {
    protocol          = "tcp"
    rule_no           = 20
    action            = "allow"
    ipv6_cidr_block   = element(local.public_subnets_6, 0)
    from_port         = 1024
    to_port           = 65535
  }

  # Requests from IP6 LB
  ingress {
    protocol          = "tcp"
    rule_no           = 11
    action            = "allow"
    ipv6_cidr_block   = element(local.public_subnets_6, 1)
    from_port         = 1024
    to_port           = 65535
  }

  # Responses to IP6 LB
  egress {
    protocol          = "tcp"
    rule_no           = 21
    action            = "allow"
    ipv6_cidr_block   = element(local.public_subnets_6, 1)
    from_port         = 1024
    to_port           = 65535
  }

  # Requests from IP6 LB
  ingress {
    protocol          = "tcp"
    rule_no           = 12
    action            = "allow"
    ipv6_cidr_block   = element(local.public_subnets_6, 2)
    from_port         = 1024
    to_port           = 65535
  }

  # Responses to IP6 LB
  egress {
    protocol          = "tcp"
    rule_no           = 22
    action            = "allow"
    ipv6_cidr_block   = element(local.public_subnets_6, 2)
    from_port         = 1024
    to_port           = 65535
  }

  # Requests from NAT GW & LB
  ingress {
    protocol          = "tcp"
    rule_no           = 100
    action            = "allow"
    cidr_block        = element(local.web_subnets_4, 0)
    from_port         = 1024
    to_port           = 65535
  }

  # Responses to NAT GW & LB
  egress {
    protocol          = "tcp"
    rule_no           = 200
    action            = "allow"
    cidr_block        = element(local.web_subnets_4, 0)
    from_port         = 1024
    to_port           = 65535
  }

  # Requests from NAT GW & LB
  ingress {
    protocol          = "tcp"
    rule_no           = 101
    action            = "allow"
    cidr_block        = element(local.web_subnets_4, 1)
    from_port         = 1024
    to_port           = 65535
  }

  # Responses to NAT GW & LB
  egress {
    protocol          = "tcp"
    rule_no           = 201
    action            = "allow"
    cidr_block        = element(local.web_subnets_4, 1)
    from_port         = 1024
    to_port           = 65535
  }

  # Requests from NAT GW & LB
  ingress {
    protocol          = "tcp"
    rule_no           = 102
    action            = "allow"
    cidr_block        = element(local.web_subnets_4, 2)
    from_port         = 1024
    to_port           = 65535
  }

  # Responses to NAT GW & LB
  egress {
    protocol          = "tcp"
    rule_no           = 202
    action            = "allow"
    cidr_block        = element(local.web_subnets_4, 2)
    from_port         = 1024
    to_port           = 65535
  }


  # Responses from Postgres
  ingress {
    protocol          = "tcp"
    rule_no           = 300
    action            = "allow"
    ipv6_cidr_block   = element(local.data_subnets_6, 0)
    from_port         = local.postgres_port
    to_port           = local.postgres_port
  }

  # Requests to Postgres
  egress {
    protocol          = "tcp"
    rule_no           = 400
    action            = "allow"
    ipv6_cidr_block   = element(local.data_subnets_6, 0)
    from_port         = local.postgres_port
    to_port           = local.postgres_port
  }

  # Responses from Postgres
  ingress {
    protocol          = "tcp"
    rule_no           = 301
    action            = "allow"
    ipv6_cidr_block   = element(local.data_subnets_6, 1)
    from_port         = local.postgres_port
    to_port           = local.postgres_port
  }

  # Requests to Postgres
  egress {
    protocol          = "tcp"
    rule_no           = 401
    action            = "allow"
    ipv6_cidr_block   = element(local.data_subnets_6, 1)
    from_port         = local.postgres_port
    to_port           = local.postgres_port
  }


  # Responses from Postgres
  ingress {
    protocol          = "tcp"
    rule_no           = 302
    action            = "allow"
    ipv6_cidr_block   = element(local.data_subnets_6, 2)
    from_port         = local.postgres_port
    to_port           = local.postgres_port
  }

  # Requests to Postgres
  egress {
    protocol          = "tcp"
    rule_no           = 402
    action            = "allow"
    ipv6_cidr_block   = element(local.data_subnets_6, 2)
    from_port         = local.postgres_port
    to_port           = local.postgres_port
  }

  # Responses from Redis
  ingress {
    protocol          = "tcp"
    rule_no           = 500
    action            = "allow"
    ipv6_cidr_block   = element(local.cache_subnets_6, 0)
    from_port         = local.redis_port
    to_port           = local.redis_port
  }

  # Requests to Redis
  egress {
    protocol          = "tcp"
    rule_no           = 600
    action            = "allow"
    ipv6_cidr_block   = element(local.cache_subnets_6, 0)
    from_port         = local.redis_port
    to_port           = local.redis_port
  }

  # Responses from Redis
  ingress {
    protocol          = "tcp"
    rule_no           = 501
    action            = "allow"
    ipv6_cidr_block   = element(local.cache_subnets_6, 1)
    from_port         = local.redis_port
    to_port           = local.redis_port
  }

  # Requests to Redis
  egress {
    protocol          = "tcp"
    rule_no           = 601
    action            = "allow"
    ipv6_cidr_block   = element(local.cache_subnets_6, 1)
    from_port         = local.redis_port
    to_port           = local.redis_port
  }

  # Responses from Redis
  ingress {
    protocol          = "tcp"
    rule_no           = 502
    action            = "allow"
    ipv6_cidr_block   = element(local.cache_subnets_6, 2)
    from_port         = local.redis_port
    to_port           = local.redis_port
  }

  # Requests to Redis
  egress {
    protocol          = "tcp"
    rule_no           = 602
    action            = "allow"
    ipv6_cidr_block   = element(local.cache_subnets_6, 2)
    from_port         = local.redis_port
    to_port           = local.redis_port
  }

  tags                = {
    Name              = "private-app"
  }

  # This resource truly depends on the VPC creating an IP6 CIDR Block,
  # and the listed dependencies serve as adequate proxies for that attribute.
  depends_on          = [
    aws_subnet.public,
    aws_subnet.private_data,
    aws_subnet.private_cache
  ]
}


resource "aws_network_acl" "private_cache" {
  vpc_id              = aws_vpc.ha_net.id
  subnet_ids          = values(aws_subnet.private_cache).*.id

  # Redis
  ingress {
    protocol          = "tcp"
    rule_no           = 10
    action            = "allow"
    ipv6_cidr_block   = element(local.k8s_pods, 0)
    from_port         = local.redis_port
    to_port           = local.redis_port
  }

  # Allow response destined for K8S Pods.
  egress {
    protocol          = "tcp"
    rule_no           = 20
    action            = "allow"
    ipv6_cidr_block   = element(local.k8s_pods, 0)
    from_port         = local.redis_port
    to_port           = local.redis_port
  }

  # Redis
  ingress {
    protocol          = "tcp"
    rule_no           = 11
    action            = "allow"
    ipv6_cidr_block   = element(local.k8s_pods, 1)
    from_port         = local.redis_port
    to_port           = local.redis_port
  }

  # Allow response destined for K8S Pods.
  egress {
    protocol          = "tcp"
    rule_no           = 21
    action            = "allow"
    ipv6_cidr_block   = element(local.k8s_pods, 1)
    from_port         = local.redis_port
    to_port           = local.redis_port
  }


  # Redis
  ingress {
    protocol          = "tcp"
    rule_no           = 12
    action            = "allow"
    ipv6_cidr_block   = element(local.k8s_pods, 2)
    from_port         = local.redis_port
    to_port           = local.redis_port
  }

  # Allow response destined for K8S Pods.
  egress {
    protocol          = "tcp"
    rule_no           = 22
    action            = "allow"
    ipv6_cidr_block   = element(local.k8s_pods, 2)
    from_port         = local.redis_port
    to_port           = local.redis_port
  }

  tags                = {
    Name              = "private-cache"
  }

  # This resource truly depends on the VPC creating an IP6 CIDR Block,
  # and the two listed dependencies serve as adequate proxies for that attribute.
  depends_on          = [
    aws_subnet.private_cache,
    aws_subnet.private_app
  ]
}
