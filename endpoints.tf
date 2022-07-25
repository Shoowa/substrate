resource "aws_vpc_endpoint" "s3" {
  vpc_id              = aws_vpc.ha_net.id
  service_name        = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = values(aws_subnet.private_app).*.id
  security_group_ids  = [aws_security_group.endpoints.id]

  tags = {
    Name = "endpoint-s3"
  }
}


resource "aws_vpc_endpoint" "ecr" {
  vpc_id              = aws_vpc.ha_net.id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = values(aws_subnet.private_app).*.id
  security_group_ids  = [aws_security_group.endpoints.id]

  tags = {
    Name = "endpoint-ecr"
  }
}


resource "aws_vpc_endpoint" "sqs" {
  vpc_id              = aws_vpc.ha_net.id
  service_name        = "com.amazonaws.${var.region}.sqs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = values(aws_subnet.private_app).*.id
  security_group_ids  = [aws_security_group.endpoints.id]

  tags = {
    Name = "endpoint-sqs"
  }
}


resource "aws_vpc_endpoint" "dynamo" {
  vpc_id              = aws_vpc.ha_net.id
  service_name        = "dynamodb.${var.region}.amazonaws.com"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = values(aws_subnet.private_app).*.id
  security_group_ids  = [aws_security_group.endpoints.id]

  tags = {
    Name = "endpoint-dynamo"
  }
}


resource "aws_vpc_endpoint" "secrets" {
  vpc_id              = aws_vpc.ha_net.id
  service_name        = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.endpoints.id]
  subnet_ids          = flatten([
    values(aws_subnet.private_data).*.id,
    values(aws_subnet.private_app).*.id
  ])

  tags = {
    Name = "endpoint-secrets"
  }
}
