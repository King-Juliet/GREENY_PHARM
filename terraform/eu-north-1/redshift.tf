#security group
resource "aws_security_group" "redshift_security_group" {
  name        = "redshift-security-group"
  description = "security group rule for redshift connections"
  vpc_id      = module.vpc_module.vpc_id
lifecycle {
    create_before_destroy = true
  }
}


#ingress rules
resource "aws_vpc_security_group_ingress_rule" "redshift_ingress_rule" {
  security_group_id = aws_security_group.redshift_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           =  5432
  tags = {
    Name = "redshift-ingress-rule"
    Owner = var.owner
  }
}


#egress rules
resource "aws_vpc_security_group_egress_rule" "redshift_egress_rule" {
  security_group_id = aws_security_group.redshift_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
  tags = {
    Name = "redshift-egress-rule"
    Owner = var.owner
  }
}


# Generate admin password for redshift
resource "random_password" "redshift_password"{
  length = 24
  special = false
}

#Save the randomly generated admin password from line 38 to ssm
module "redshift_admin_password" {
  source = "../modules/ssm_parameter"
  ssm_param_name = "/redshift/admin_password"
  ssm_param_type = "String"
  ssm_param_value = random_password.redshift_password.result
}


#redshift
module "greeny_redshift_serverless" {
  source = "../modules/redshift"
  namespace_name = "greeny-data-namespace"
  db_name = "business-analytics"
  admin_username = "aduser"
  admin_user_password = module.redshift_admin_password.ssm_param_value
  kms_key_arn = aws_kms_key.kms.arn
  owner = var.owner
  workgroup_name = "greeny-data-workgroup"
  base_capacity = 8
  security_group_ids = [aws_security_group.redshift_security_group.id]
  subnet_ids = [module.redshift_subnet.subnet_id]
}
