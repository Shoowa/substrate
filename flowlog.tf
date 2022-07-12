resource "aws_s3_bucket" "vpc_flow_log" {
  bucket  = "flowlogs-vpc-${var.region}-${var.environ}-${var.corp}"

  tags    = {
    Name  = "flowlogs-vpc-${var.region}-${var.environ}-${var.corp}"
  }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "vpc_flow_log" {
  bucket = aws_s3_bucket.vpc_flow_log.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


resource "aws_s3_bucket_lifecycle_configuration" "vpc_flow_log" {
  bucket = aws_s3_bucket.vpc_flow_log.bucket

  rule {
    id          = "total-bucket"
    status      = "Enabled"
    filter {}   # Apply to all objects.

    transition      {
      days          = 60
      storage_class = local.flex_glacier
    }

    transition      {
      days          = 60 + 91
      storage_class = local.deep_glacier
    }
  }
}


resource "aws_flow_log" "vpc" {
  vpc_id                  = aws_vpc.ha_net.id
  log_destination_type    = "s3"
  log_destination         = aws_s3_bucket.vpc_flow_log.arn
  traffic_type            = "ALL"

  destination_options {
    file_format           = "parquet"
    per_hour_partition    = "true"
  }
}


resource "aws_s3_bucket" "private_data_flow_log" {
  for_each  = local.map_az_index
  bucket    = "flowlogs-private-data-${each.key}-${var.environ}-${var.corp}"

  tags      = {
    Name    = "flowlogs-private-data-${each.key}-${var.environ}-${var.corp}"
  }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "private_data_flow_log" {
  for_each  = local.map_az_index
  bucket    = aws_s3_bucket.private_data_flow_log[each.key].bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


resource "aws_s3_bucket_lifecycle_configuration" "private_data_flow_log" {
  for_each  = local.map_az_index
  bucket    = aws_s3_bucket.private_data_flow_log[each.key].bucket

  rule {
    id          = "total-bucket"
    status      = "Enabled"
    filter {}   # Apply to all objects.

    transition      {
      days          = 60
      storage_class = local.flex_glacier
    }

    transition      {
      days          = 60 + 91
      storage_class = local.deep_glacier
    }
  }
}


resource "aws_flow_log" "private_data" {
  for_each                = local.map_az_index

  subnet_id               = aws_subnet.private_data[each.key].id
  log_destination_type    = "s3"
  log_destination         = aws_s3_bucket.private_data_flow_log[each.key].arn
  traffic_type            = "ALL"

  destination_options {
    file_format           = "parquet"
    per_hour_partition    = "true"
  }
}
