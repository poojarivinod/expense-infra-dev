resource "aws_ssm_parameter" "mysql_sg_id" { # ssm parameter store terraform --> terraform registry
  name  = "/${var.project_name}/${var.environment}/mysql_sg_id"
  type  = "String"
  value = module.mysql_sg.sg_id
}

