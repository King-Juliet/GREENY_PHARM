#security group
resource "aws_security_group" "rds_security_group" {
  name        = "rds-security-group"
  description = "security group rule for rds connections"
  vpc_id      = module.vpc_module.vpc_id
lifecycle {
    create_before_destroy = true
  }
}


#ingress rules
resource "aws_vpc_security_group_ingress_rule" "rds_ingress_rule" {
  security_group_id = aws_security_group.rds_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           =  5432
  tags = {
    Name = "rds-ingress-rule"
    Owner = var.owner
  }
}


#egress rules
resource "aws_vpc_security_group_egress_rule" "rds_egress_rule" {
  security_group_id = aws_security_group.rds_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
  tags = {
    Name = "rds-egress-rule"
    Owner = var.owner
  }
}


#subnet
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [module.rds_subnet.subnet_id] 

  tags = {
    Name = "RDS subnet group"
  }
}


#Generate admin password for postgres RDS
resource "random_password" "rds_password"{
  length = 24
  special = false
}

#Save the randomly generated admin password from line 49 to ssm
module "rds_admin_password" {
  source = "../modules/ssm_parameter"
  ssm_param_name = "/rds/admin_password"
  ssm_param_type = "String"
  ssm_param_value = random_password.rds_password.result
}


#rds
module "greeny_rds" {
  source = "../modules/rds"
  allocated_storage = 20
  max_allocated_storage = 100 #Enable autoscaling up to 100GB max
  instance_class = "db.t3.micro"
  storage_type = "gp2"
  db_name = "greeny_data"
  username = "juli"
  password = module.rds_admin_password.ssm_param_value
  multi_az = false
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  kms_key_arn = aws_kms_key.kms.arn
}