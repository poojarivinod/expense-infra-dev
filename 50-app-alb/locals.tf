locals {
    private_subnet_id = split(",", data.aws_ssm_parameter.private_subnet_id.value)
# in aws value are stored in the form of stringlist, which converted into  list
    app_alb_sg_id = data.aws_ssm_parameter.app_alb_sg_id.value
}