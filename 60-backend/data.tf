data "aws_ami" "joindevops" { #data source aws ami terraform
  most_recent = true
  owners      = ["973714476881"] #Owner account ID ( it never changes and fixed)

  filter {
    name   = "name"
    values = ["RHEL-9-DevOps-Practice"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

# it read the content of /expense/dev//vpc_id ssm parameter
data "aws_ssm_parameter" "backend_sg_id" { # parameter store in aws data source terraform --> terraform registry
  name = "/${var.project_name}/${var.environment}/backend_sg_id"
}

# it read the content of /expense/dev//vpc_id ssm parameter
data "aws_ssm_parameter" "private_subnet_id" { # parameter store in aws data source terraform --> terraform registry
  name = "/${var.project_name}/${var.environment}/private_subnet_id"
} # we get output in string of public subnet ids