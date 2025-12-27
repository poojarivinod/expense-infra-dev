resource "aws_cloudfront_distribution" "expense" { #aws cdn terraform --> terraform registry
  origin {
    domain_name              = "${var.project_name}-${var.environment}.${var.domain_name}"
    origin_id                = "${var.project_name}-${var.environment}.${var.domain_name}"
    custom_origin_config  {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  aliases = ["${var.project_name}-cdn.${domain_name}"]

  #Cache behaviour with precedence 2
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.project_name}-${var.environment}.${var.domain_name}"
    viewer_protocol_policy = "https-only"
    cache_policy_id        = data.aws_cloudfront_cache_policy.noCache.id  #data source aws cdn cache policy  terraform
    #hardcode--> cloudfront>policies>CachingDisabled> there we get cache_policy_id
  }
  
    #Cache behaviour with precedence 0
    ordered_cache_behavior {
    path_pattern     = "/images/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${var.project_name}-${var.environment}.${var.domain_name}"
    viewer_protocol_policy = "https-only"
    cache_policy_id        = data.aws_cloudfront_cache_policy.cacheEnable.id  #data source aws cdn cache policy  terraform
    #hardcode--> cloudfront>policies>CachingDisabled> there we get cache_policy_id
  
  }

    #Cache behaviour with precedence 1
   ordered_cache_behavior {
    path_pattern     = "/static/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${var.project_name}-${var.environment}.${var.domain_name}"
    viewer_protocol_policy = "https-only"
    cache_policy_id        = data.aws_cloudfront_cache_policy.cacheEnable.id  #data source aws cdn cache policy  terraform
    #hardcode--> cloudfront>policies>CachingDisabled> there we get cache_policy_id
  
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["IN"]
    }
  }

  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}"
    }
  )

  viewer_certificate { #aws cdn terraform -->viewer_certificate--> SSL configuration
    acm_certificate_arn = local.https_certificate_arn
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
  
resource "aws_route53_record" "cdn" { # aws route 53 record terraform --> terraform registry
  zone_id = var.zone_id
  name    =  "expense-cdn.${var.domain_name}"
  type    = "A"

# these are ALB DNS name and zone information 
  alias {
    name                   = aws_cloudfront_distribution.expense.domain_name #aws cdn terraform --> terraform registry  
    zone_id                = aws_cloudfront_distribution.expense.hosted_zone_id 
    evaluate_target_health = false
  }
  allow_overwrite = true #aws route 53 record terraform  --> terraform registry
}

