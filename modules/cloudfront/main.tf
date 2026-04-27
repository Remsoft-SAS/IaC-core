# modules/cloudfront/main.tf

# 0. Lookup certificate if domain is provided (Must be in us-east-1)
data "aws_acm_certificate" "issued" {
  count    = var.certificate_domain != null ? 1 : 0
  domain   = var.certificate_domain
  statuses = ["ISSUED"]
}

locals {
  final_certificate_arn = var.certificate_domain != null ? data.aws_acm_certificate.issued[0].arn : null
}

# 1. CloudFront Function: URL Rewrite (Multi-page support)
resource "aws_cloudfront_function" "url_rewrite" {
  count   = var.enable_url_rewrite ? 1 : 0
  name    = replace(replace(replace("${var.comment}-${var.environment}-rewrite", " ", "-"), "(", ""), ")", "")
  runtime = "cloudfront-js-2.0"
  publish = true
  code    = <<EOF
function handler(event) {
    var request = event.request;
    var uri = request.uri;
    if (uri.endsWith('/')) { request.uri += 'index.html'; }
    else if (!uri.includes('.')) { request.uri += '/index.html'; }
    return request;
}
EOF
}

# 2. Security Headers Policy
resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name    = replace(replace(replace("${var.comment}-${var.environment}-security", " ", "-"), "(", ""), ")", "")
  security_headers_config {
    frame_options { frame_option = "DENY"; override = true }
    content_type_options { override = true }
    xss_protection { mode_block = true; protection = true; override = true }
    referrer_policy { referrer_policy = "strict-origin-when-cross-origin"; override = true }
    strict_transport_security { access_control_max_age_sec = 31536000; include_subdomains = true; preload = true; override = true }
  }
}

# 3. Origin Access Control (OAC) for S3
resource "aws_cloudfront_origin_access_control" "s3" {
  name                              = "${var.comment}-${var.environment}-s3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# 4. Main Distribution
resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  http_version        = "http2and3"
  comment             = "${var.comment} (${var.environment})"
  default_root_object = var.default_root_object
  price_class         = var.price_class
  web_acl_id          = var.web_acl_id

  aliases = var.aliases

  # --- Origins ---
  
  # Static Origin (S3)
  origin {
    domain_name              = var.s3_bucket_domain_name
    origin_id                = "S3Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3.id
  }

  # Dynamic Origin (API Gateway)
  dynamic "origin" {
    for_each = var.api_gateway_domain_name != null ? [1] : []
    content {
      domain_name = var.api_gateway_domain_name
      origin_id   = "APIOrigin"
      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  # --- Behaviors ---

  # API Behavior (If API Gateway is provided)
  dynamic "ordered_cache_behavior" {
    for_each = var.api_gateway_domain_name != null ? [1] : []
    content {
      path_pattern     = var.api_path_pattern
      allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods   = ["GET", "HEAD"]
      target_origin_id = "APIOrigin"

      forwarded_values {
        query_string = true
        headers      = ["Authorization", "Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
        cookies { forward = "all" }
      }

      viewer_protocol_policy = "redirect-to-https"
      min_ttl                = 0
      default_ttl            = 0
      max_ttl                = 0
    }
  }

  # Default Behavior (S3)
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"

    viewer_protocol_policy     = "redirect-to-https"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id

    forwarded_values {
      query_string = false
      headers      = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
      cookies { forward = "none" }
    }

    dynamic "function_association" {
      for_each = var.enable_url_rewrite ? [1] : []
      content {
        event_type   = "viewer-request"
        function_arn = aws_cloudfront_function.url_rewrite[0].arn
      }
    }
  }

  # SPA Support
  dynamic "custom_error_response" {
    for_each = var.is_spa ? [403, 404] : []
    content {
      error_code         = custom_error_response.value
      response_code      = 200
      response_page_path = "/index.html"
    }
  }

  restrictions { geo_restriction { restriction_type = "none" } }

  viewer_certificate {
    acm_certificate_arn            = local.final_certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
    cloudfront_default_certificate = local.final_certificate_arn == null
  }

  tags = merge({ Environment = var.environment }, var.tags)
}
