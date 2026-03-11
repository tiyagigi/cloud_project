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

# S3 Bucket for Static Assets
resource "aws_s3_bucket" "portfolio_assets" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_ownership_controls" "portfolio_assets" {
  bucket = aws_s3_bucket.portfolio_assets.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "portfolio_assets" {
  depends_on = [aws_s3_bucket_ownership_controls.portfolio_assets]
  bucket     = aws_s3_bucket.portfolio_assets.id
  acl        = "private"
}

# CloudFront Origin Access Identity (OAI)
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for Group 7 Portfolio assets"
}

# S3 Bucket Policy to allow CloudFront
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.portfolio_assets.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "portfolio_assets_policy" {
  bucket = aws_s3_bucket.portfolio_assets.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "portfolio_cdn" {
  origin {
    domain_name = aws_s3_bucket.portfolio_assets.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.portfolio_assets.id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Group 7 Global CDN"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.portfolio_assets.id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
