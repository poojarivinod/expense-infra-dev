# security group module for mysql
module "mysql_sg" {
    # source = "..//terraform-aws-securitygroup" #for testing , once completed use below source
    source = "git::https://github.com/poojarivinod/terraform-aws-securitygroup.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "mysql"
    sg_description = "created for MySQL instance in expense dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value # # it read the content of /expense/dev//vpc_id ssm parameter
    common_tags = var.common_tags
}

# security group module for backend
module "backend_sg" {
    # source = "..//terraform-aws-securitygroup" #for testing , once completed use below source
    source = "git::https://github.com/poojarivinod/terraform-aws-securitygroup.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "backend"
    sg_description = "created for backend instance in expense dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value # # it read the content of /expense/dev//vpc_id ssm parameter
    common_tags = var.common_tags
}

# security group module for frontend
module "frontend_sg" { # every module we add, we need to pass "terraform init" otherwise it will show error
    # source = "..//terraform-aws-securitygroup" #for testing , once completed use below source
    source = "git::https://github.com/poojarivinod/terraform-aws-securitygroup.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "frontend"
    sg_description = "created for frontend instance in expense dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value # # it read the content of /expense/dev//vpc_id ssm parameter
    common_tags = var.common_tags
}

# security group module for bastion
module "bastion_sg" { # every module we add, we need to pass "terraform init" otherwise it will show error
    # source = "..//terraform-aws-securitygroup" #for testing , once completed use below source
    source = "git::https://github.com/poojarivinod/terraform-aws-securitygroup.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "bastion"
    sg_description = "created for bastion instance in expense dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value # # it read the content of /expense/dev//vpc_id ssm parameter
    common_tags = var.common_tags
}

# security group module for vpn , vpn ports are 22, 443, 1194, 943.
module "vpn_sg" { # every module we add, we need to pass "terraform init" otherwise it will show error
    # source = "..//terraform-aws-securitygroup" #for testing , once completed use below source
    source = "git::https://github.com/poojarivinod/terraform-aws-securitygroup.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "vpn"
    sg_description = "created for vpn instance in expense dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value # # it read the content of /expense/dev//vpc_id ssm parameter
    common_tags = var.common_tags
}

# security group module for app_alb 
module "app_alb_sg" { # every module we add, we need to pass "terraform init" otherwise it will show error
    # source = "..//terraform-aws-securitygroup" #for testing , once completed use below source
    source = "git::https://github.com/poojarivinod/terraform-aws-securitygroup.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "app-alb"
    sg_description = "created for backend ALB instance in expense dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value # # it read the content of /expense/dev//vpc_id ssm parameter
    common_tags = var.common_tags
}

# app load balancer accept the traffic from bastion host
resource "aws_security_group_rule" "app_alb_bastion" { # terraform aws security group rule --> terraform registry
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id    =  module.bastion_sg.sg_id # accept bastion host id
  security_group_id = module.app_alb_sg.sg_id
}

# To get traffic from internet to bastion
resource "aws_security_group_rule" "bastion_public" { # terraform aws security group rule --> terraform registry
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  # we can give home ip address(search in internet as "what is my ip"), it is dynamic ip addreess, in company we have purchased static ip address we use it
  security_group_id = module.bastion_sg.sg_id
}

# To get traffic from internet to vpn
resource "aws_security_group_rule" "vpn_ssh" { # terraform aws security group rule --> terraform registry
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"] 
  security_group_id = module.vpn_sg.sg_id
}

# vpn traffic
resource "aws_security_group_rule" "vpn_443" { # terraform aws security group rule --> terraform registry
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"] 
  security_group_id = module.vpn_sg.sg_id
}

# vpn traffic
resource "aws_security_group_rule" "vpn_943" { # terraform aws security group rule --> terraform registry
  type              = "ingress"
  from_port         = 943
  to_port           = 943
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"] 
  security_group_id = module.vpn_sg.sg_id
}

# vpn traffic
resource "aws_security_group_rule" "vpn_1194" { # terraform aws security group rule --> terraform registry
  type              = "ingress"
  from_port         = 1194
  to_port           = 1194
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"] 
  security_group_id = module.vpn_sg.sg_id
}

# app load balancer accept the traffic from vpn
resource "aws_security_group_rule" "app_alb_vpn" { # app_alb accepting traffic through vpn
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.sg_id
  security_group_id = module.app_alb_sg.sg_id
}

# mysql accept the traffic from bastion
resource "aws_security_group_rule" "mysql_bastion" { # mysql accepting traffic through bastion
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.mysql_sg.sg_id
}

# mysql accept the traffic from vpn
resource "aws_security_group_rule" "mysql_vpn" { # mysql accepting traffic through bastion
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.sg_id
  security_group_id = module.mysql_sg.sg_id
}

# backend accept the traffic from vpn
resource "aws_security_group_rule" "backend_vpn" { # mysql accepting traffic through bastion
  type              = "ingress"
  from_port         = 22 # to have ssh access
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.sg_id
  security_group_id = module.backend_sg.sg_id
}

# mysql accept the traffic from backend
resource "aws_security_group_rule" "mysql_backend" { # mysql accepting traffic through bastion
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.backend_sg.sg_id
  security_group_id = module.mysql_sg.sg_id
}

