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

