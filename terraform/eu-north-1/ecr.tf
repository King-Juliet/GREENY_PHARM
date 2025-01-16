module "greeny_ecr" {
  source = "../modules/ECR"
  repository_name = "lambda_repo"
  image_tag_mutability = "MUTABLE"
}