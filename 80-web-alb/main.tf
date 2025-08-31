module "alb" { # terraform aws lbs --> application load balancer github
  source = "terraform-aws-modules/alb/aws" # it will take from github

 # expense-dev-app-alb
  name    = "${var.project_name}-${var.environment}-web-alb"
  vpc_id  = data.aws_ssm_parameter.vpc_id.value
  subnets = local.public_subnet_ids # this is frontend load balancer , so we need to give public subnet ids.
  create_security_group = false # terraform aws lbs --> github --> search as security_group --> inputs --> create_security_group is default is false(move side) 
  security_groups = [local.web_alb_sg_id] # it is the list
  internal = false # because this load balancer is open to the public
  enable_deletion_protection = false # by default it is true, if it is true we can't delete load balancer

  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-web-alb"
    }
  )
}

resource "aws_lb_listener" "https" { #aws alb listener --> terrafrom registry
  load_balancer_arn = module.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = local.web_alb_certificate_arn

 default_action {
    type = "fixed-response" # still we don't have backend application instance, so we are using the fixed response for testing purpose

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hello, I am from backend APP ALB</h1>"
      status_code  = "200"
  }
}  
}

resource "aws_route53_record" "web_alb" { # aws route 53 record terraform --> terraform registry
  zone_id = var.zone_id
  name    = "*.${var.domain_name}"
  type    = "A"

# these are ALB DNS name and zone information 
  alias {
    name                   = module.alb.dns_name # it is alb dns name
    zone_id                = module.alb.zone_id # it is alb zone id
    evaluate_target_health = false
  }
}