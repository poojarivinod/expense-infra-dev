data "aws_cloudfront_cache_policy" "noCache" { #data source aws cdn cache policy  terraform
  name = "Managed-CachingDisabled"  #hardcode--> cloudfront>policies>CachingDisabled> there we get cache_policy_name
}

data "aws_cloudfront_cache_policy" "cacheEnable" { #data source aws cdn cache policy  terraform
  name = "Managed-CachingOptimized"  #hardcode--> cloudfront>policies>CachingDisabled> there we get cache_policy_name
}

data "aws_ssm_parameter" "https_certificate_arn" { # parameter store in aws data source terraform --> terraform registry
  name = "/${var.project_name}/${var.environment}/web_alb_certificate_arn"
}
