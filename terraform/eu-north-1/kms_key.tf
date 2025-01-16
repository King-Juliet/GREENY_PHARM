resource "aws_kms_key" "kms" {
  description = "for encryption of data rest"
  enable_key_rotation = true
}
