variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name for the S3 bucket holding CDN assets (must be globally unique)"
  type        = string
  default     = "group7-portfolio-assets-unique-id"
}
