resource "aws_security_group" "allow_tls" {
  vpc_id              = aws_vpc.ha_net.id
  name                = "allow-tls"
  description         = "Allow TLS inbound traffic."

  # Rules are stateful, so a response is allowed for secure inbound requests.
  ingress {
    description       = "TLS from VPC."
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = [aws_vpc.ha_net.cidr_block]
    ipv6_cidr_blocks  = [aws_vpc.ha_net.ipv6_cidr_block]
  }

  # Allow ANY outbound request.
  egress {
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = [local.zero_ip4]
    ipv6_cidr_blocks  = [local.zero_ip6]
  }
}


resource "aws_security_group" "postgres" {
  vpc_id              = aws_vpc.ha_net.id
  name                = "postgres"
  description         = "Allow requests to Postgres."

  # Rules are stateful, so a response is allowed for secure inbound requests.
  ingress {
    description       = "TLS from VPC."
    from_port         = 5432
    to_port           = 5432
    protocol          = "tcp"
    ipv6_cidr_blocks  = [aws_vpc.ha_net.ipv6_cidr_block]
  }

  # Allow ANY outbound request.
  egress {
    from_port         = 0
    to_port           = 0
    protocol          = "tcp"
    ipv6_cidr_blocks  = [aws_vpc.ha_net.ipv6_cidr_block]
  }
}
