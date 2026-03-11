variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "The registered domain name (e.g., example.com)"
  type        = string
}

variable "eks_load_balancer_hostname" {
  description = "The hostname of the AWS Load Balancer pointing to EKS"
  type        = string
}
