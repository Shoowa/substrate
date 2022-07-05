# Stateless so both ingress & egress must be defined.
resource "aws_network_acl" "private_data" {
  vpc_id              = aws_vpc.ha_net.id
  subnet_ids          = [for subnet in aws_subnet.private_data: subnet.id]

  # Postgres
  ingress {
    protocol          = "tcp"
    rule_no           = 10
    action            = "allow"
    ipv6_cidr_block   = aws_vpc.ha_net.ipv6_cidr_block
    from_port         = 5432
    to_port           = 5432
  }

  # Postgres
  egress {
    protocol          = "tcp"
    rule_no           = 20
    action            = "allow"
    ipv6_cidr_block   = aws_vpc.ha_net.ipv6_cidr_block
    from_port         = 5432
    to_port           = 5432
  }
}
