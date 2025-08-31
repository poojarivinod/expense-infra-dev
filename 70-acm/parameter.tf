resource "aws_ssm_parameter" "web_alb_certificate_arn" { # ssm parameter store terraform --> terraform registry
  name  = "/${var.project_name}/${var.environment}/web_alb_certificate_arn"
  type  = "String"
  value = aws_acm_certificate.expense.arn
} 