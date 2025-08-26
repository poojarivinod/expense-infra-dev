data "aws_ami" "openvpn" { #data source aws ami terraform
  most_recent = true
  owners      = ["679593333241"] # launch instance--> openvpn access server community--> there we can get owner id
  #Owner account ID ( it never changes and fixed)

  filter {
    name   = "name"
    values = ["OpenVPN Access Server Community Image-fe8020db-*"] # launch instance--> openvpn access server community--> there we can get name
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
data "aws_ssm_parameter" "vpn_sg_id" { # parameter store in aws data source terraform --> terraform registry
  name = "/${var.project_name}/${var.environment}/vpn_sg_id"
}

# it read the content of /expense/dev//vpc_id ssm parameter
data "aws_ssm_parameter" "public_subnet_ids" { # parameter store in aws data source terraform --> terraform registry
  name = "/${var.project_name}/${var.environment}/public_subnet_ids"
} # we get output in string of public subnet ids