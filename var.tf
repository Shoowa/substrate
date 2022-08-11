variable "environ" {
  type        = string
  description = "Name of environment"
  default     = "production"
}


variable "region" {
  type        = string
  description = "Name of AWS region"
  default     = "us-east-2"
}


variable "corp" {
  type        = string
  description = "Name of the corporation"
}


variable "cluster_name" {
  type        = string
  description = "Name of the future EKS cluster."
}


variable "endpoint_s3" {
  type        = bool
  description = "Toggle VPC Endpoint for S3 service."
  default     = false
}


variable "endpoint_sqs" {
  type        = bool
  description = "Toggle VPC Endpoint for SQS service."
  default     = false
}


variable "endpoint_ecr" {
  type        = bool
  description = "Toggle VPC Endpoint for ECR service."
  default     = false
}


variable "endpoint_dynamo" {
  type        = bool
  description = "Toggle VPC Endpoint for DynamoDB service."
  default     = false
}


variable "endpoint_secrets" {
  type        = bool
  description = "Toggle VPC Endpoint for Secrets Manager service."
  default     = false
}


variable "dns_name" {
  type        = string
  description = "Name of the domain."
}
