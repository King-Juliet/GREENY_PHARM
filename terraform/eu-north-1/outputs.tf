#iam outputs
output "users_arn"{
    description = "arn for all the created iam users"
    value = ["${aws_iam_user.iam_users.*.arn}"]
}

#ecr repository url
output "repository_url"{
    description = "url for ECR"
    value = module.greeny_ecr.repository_url
}


#kms id
output "kms_arn" {
  description = "ARN for kms"
  value = aws_kms_key.kms.arn
}


#step function arn
output "stfn_state_machine_arn" {
  value = aws_sfn_state_machine.stfn_state_machine.arn
}