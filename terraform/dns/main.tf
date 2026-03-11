terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Assume the EKS cluster and Hosted Zone already exist 
# (since creating an EKS cluster from scratch via TF is a massive project on its own)
data "aws_route53_zone" "primary" {
  name = var.domain_name
}

# Note: In a real environment, you might fetch the LoadBalancer hostname
# from a Kubernetes Service using the kubernetes provider. For simplicity, 
# we allow passing it as a variable.
resource "aws_route53_record" "portfolio_dns" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "portfolio.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [var.eks_load_balancer_hostname]
}
