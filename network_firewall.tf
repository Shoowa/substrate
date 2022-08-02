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

  # VPC Endpoint
  ingress {
    protocol          = "tcp"
    rule_no           = 200
    action            = "allow"
    cidr_block        = local.zero_ip4
    from_port         = 443
    to_port           = 443
  }

  # VPC Endpoint
  egress {
    protocol          = "tcp"
    rule_no           = 210
    action            = "allow"
    cidr_block        = local.zero_ip4
    from_port         = 443
    to_port           = 443
  }

  # Lambda
  ingress {
    protocol          = "tcp"
    rule_no           = 300
    action            = "allow"
    cidr_block        = local.zero_ip4
    from_port         = 1024
    to_port           = 65535
  }

  # Lambda
  egress {
    protocol          = "tcp"
    rule_no           = 310
    action            = "allow"
    cidr_block        = local.zero_ip4
    from_port         = 1024
    to_port           = 65535
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
