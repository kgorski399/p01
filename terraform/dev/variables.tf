data "aws_caller_identity" "current" {}

variable "region" {
  default = "us-east-1"
}

variable "bucket_name" {
  type = string
}

variable "env" {
  description = "Środowisko (dev, prod)"
  default     = "dev"
}
