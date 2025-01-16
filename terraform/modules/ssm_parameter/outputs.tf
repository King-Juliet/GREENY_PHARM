output "ssm_param_arn"{
    description = "arn for ssm parameter store"
    value = aws_ssm_parameter.ssm_parameter_store.arn
}


output "ssm_param_value"{
    description = "value for ssm parameter store"
    value = aws_ssm_parameter.ssm_parameter_store.value
}