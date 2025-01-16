# Namespace
resource "aws_redshiftserverless_namespace" "redshift_namespace" {
  namespace_name = var.namespace_name
  db_name        = var.db_name
  admin_username = var.admin_username
  admin_user_password = var.admin_user_password
  kms_key_id = var.kms_key_arn
  tags = {
    Owner = var.owner
  }
}

# Workgroup
resource "aws_redshiftserverless_workgroup" "redshift_workgroup" {
  workgroup_name     = var.workgroup_name
  namespace_name     = var.namespace_name
  base_capacity      = var.base_capacity
  publicly_accessible = false
  security_group_ids = var.security_group_ids
  subnet_ids          = var.subnet_ids

  tags = {
    Owner = var.owner
  }
}