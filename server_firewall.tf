resource "aws_security_group" "lb_allow_tls" {
  vpc_id              = aws_vpc.ha_net.id
  name                = "allow-tls"
  description         = "Allow TLS inbound traffic."

  # Rules are stateful, so a response is allowed for secure inbound requests.
  ingress {
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = [local.zero_ip4]
    ipv6_cidr_blocks  = [local.zero_ip6]
  }

  # Allow outbound requests to only the private_app subnet.
  egress {
    from_port         = 1024
    to_port           = 65535
    protocol          = "tcp"
    cidr_blocks       = local.k8s_nodes
    ipv6_cidr_blocks  = local.k8s_pods
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "lb_tls"
  }

  # This resource truly depends on the VPC creating an IP6 CIDR Block,
  # and the listed dependency serves as an adequate proxy for that attribute.
  depends_on = [aws_subnet.private_app]
}


# TF prohibits an egress ALLOW ALL rule by default.
resource "aws_security_group" "postgres" {
  vpc_id              = aws_vpc.ha_net.id
  name                = "postgres"
  description         = "Allow requests from the private-app IP6 subnets to Postgres."

  # Rules are stateful, so a response is allowed for secure inbound requests.
  ingress {
    description       = "Allow K8S pods to contact Postgres."
    from_port         = local.postgres_port
    to_port           = local.postgres_port
    protocol          = "tcp"
    ipv6_cidr_blocks  = local.k8s_pods
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "postgres"
  }

  # This resource truly depends on the VPC creating an IP6 CIDR Block,
  # and the listed dependency serves as an adequate proxy for that attribute.
  depends_on = [aws_subnet.private_app]
}


resource "aws_security_group" "endpoints" {
  vpc_id              = aws_vpc.ha_net.id
  name                = "endpoints"
  description         = "Allow endpoints to receive requests from private-app subnets."

  # Rules are stateful, so a response is allowed for secure inbound requests.
  ingress {
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = [local.zero_ip4]
    ipv6_cidr_blocks  = [local.zero_ip6]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "endpoints-inbound"
  }
}


resource "aws_security_group" "cred_rotation_lambda" {
  vpc_id        = aws_vpc.ha_net.id
  name          = "allow-cred-rotation"
  description   = "Allow Lambda func to contact both RDS & SM Endpoint."

  egress {
    description       = "Lambda to RDS"
    from_port         = local.postgres_port
    to_port           = local.postgres_port
    protocol          = "tcp"
    cidr_blocks       = local.data_subnets_4
  }

  egress {
    description       = "Lambda to Endpoint Secrets Manager."
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = [local.zero_ip4]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "firewall-lambda"
  }
}
