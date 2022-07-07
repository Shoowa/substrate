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
    cidr_blocks       = [for subnet in local.k8s_nodes: subnet]
    ipv6_cidr_blocks  = [for subnet in local.k8s_pods: subnet]
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
    description       = "TLS from VPC."
    from_port         = 5432
    to_port           = 5432
    protocol          = "tcp"
    ipv6_cidr_blocks  = [for subnet in local.k8s_pods: subnet]
  }

  tags = {
    Name = "postgres"
  }

  # This resource truly depends on the VPC creating an IP6 CIDR Block,
  # and the listed dependency serves as an adequate proxy for that attribute.
  depends_on = [aws_subnet.private_app]
}
