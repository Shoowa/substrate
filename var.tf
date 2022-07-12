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
