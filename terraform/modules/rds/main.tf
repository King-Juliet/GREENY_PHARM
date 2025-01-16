resource "aws_db_instance" "rds" {
    engine                 = "postgres"
    allocated_storage      = var.allocated_storage
    max_allocated_storage  = var.max_allocated_storage
    instance_class         = var.instance_class
    storage_type           = var.storage_type
    db_name                = var.db_name
    username               = var.username
    password               = var.password
    port                   = 5432
    publicly_accessible    = true
    backup_retention_period = 7
    multi_az               = var.multi_az
    vpc_security_group_ids = var.vpc_security_group_ids
    skip_final_snapshot    = true
    db_subnet_group_name  = var.db_subnet_group_name
    storage_encrypted       = true
    kms_key_id              = var.kms_key_arn
}