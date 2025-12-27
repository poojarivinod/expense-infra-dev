locals {
    public_subnet_id = split(",", data.aws_ssm_parameter.public_subnet_id.value)[0]
    public_subnet_ids = split(",", data.aws_ssm_parameter.public_subnet_id.value)
    resource_name = "${var.project_name}-${var.environment}-frontend"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    frontend_sg_id = data.aws_ssm_parameter.frontend_sg_id.value
    web_alb_listener_arn = data.aws_ssm_parameter.web_alb_listener_arn.value
} # it will convert terraform string into list , from that list of value we take first public subnet id 