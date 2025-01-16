resource "aws_ssm_parameter" "ssm_parameter_store"{
  name = var.ssm_param_name
  type = var.ssm_param_type
  value = var.ssm_param_value
}