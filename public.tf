resource "aws_internet_gateway" "app_gateway" {
  vpc_id              = aws_vpc.ha_net.id

  tags = {
    Name = "gateway"
    ip   = "4"
  }
}


resource "aws_route_table" "public" {
  vpc_id  = aws_vpc.ha_net.id


  route {
    cidr_block = local.zero_ip4
    gateway_id = aws_internet_gateway.app_gateway.id
  }

  tags = {
    Name = "public-routes"
    type = "public"
  }
}


# Each public subnet linked to the IGW.
resource "aws_route_table_association" "public" {
  for_each          = toset(local.azs)

  route_table_id    = aws_route_table.public.id
  subnet_id         = aws_subnet.public[each.key].id

  depends_on        = [aws_subnet.public]
}


# Relevant for only IP4-to-IP4 transmissions.
resource "aws_eip" "nat" {
  for_each    = toset(local.azs)

  vpc         = true

  tags      = {
    Name    = "eip"
    region  = "${each.key}"
    type    = "public"
  }

  depends_on  = [aws_internet_gateway.app_gateway]
}


# Pair EIP and NAT Gateways by AZ.
resource "aws_nat_gateway" "ec2_to_igw" {
  for_each        = toset(local.azs)

  allocation_id   = aws_eip.nat[each.key].id
  subnet_id       = aws_subnet.public[each.key].id

  tags = {
    Name = "nat-${each.key}"
    type = "public"
  }

  depends_on = [
    aws_internet_gateway.app_gateway,
    aws_subnet.public,
    aws_eip.nat
  ]
}
