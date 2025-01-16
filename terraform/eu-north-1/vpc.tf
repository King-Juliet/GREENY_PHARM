#set vpc cidr block range
module "vpc_module" {
  source = "../modules/vpc"
  vpc_cidr = "10.0.0.0/16"
  vpc_name = "Greeny pharmaceutical analytics VPC"
  vpc_owner = var.owner
}


#get availability zones available
data "aws_availability_zones" "azs" {
  state = "available"
}


#rds subnet
module "rds_subnet" {
  source = "../modules/subnets"
  vpc_id = module.vpc_module.vpc_id
  subnet_cidr = "10.0.0.0/24"
  az = data.aws_availability_zones.azs.names[0]
  subnet_name = "rds_subnet"
  subnet_owner = var.owner
}


#redshift subnet
module "redshift_subnet" {
  source = "../modules/subnets"
  vpc_id = module.vpc_module.vpc_id
  subnet_cidr = "10.0.2.0/24"
  az = data.aws_availability_zones.azs.names[0]
  subnet_name = "redshift_subnet"
  subnet_owner = var.owner
}


#lambda subnet
module "lambda_subnet" {
  source = "../modules/subnets"
  vpc_id = module.vpc_module.vpc_id
  subnet_cidr = "10.0.3.0/24"
  az = data.aws_availability_zones.azs.names[0]
  subnet_name = "lambda_subnet"
  subnet_owner = var.owner
}


#route table for rds
resource "aws_route_table" "rds_route_table" {
   vpc_id = module.vpc_module.vpc_id

   route {
     cidr_block = "10.0.0.0/16"
     gateway_id = "local"  # Local gateway, which is the default for communication within the VPC
   }

   tags = {
     Name = "rds route table"
     Owner= var.owner
   }
 }


#route table for redshift
resource "aws_route_table" "redshift_route_table" {
   vpc_id = module.vpc_module.vpc_id

   route {
     cidr_block = "10.0.0.0/16"
     gateway_id = "local"  # Local gateway, which is the default for communication within the VPC
   }

   tags = {
     Name = "redshift route table"
     Owner= var.owner
   }
 }


#route table for redshift
resource "aws_route_table" "lambda_route_table" {
   vpc_id = module.vpc_module.vpc_id

   route {
     cidr_block = "10.0.0.0/16"
     gateway_id = "local"  # Local gateway, which is the default for communication within the VPC
   }

   tags = {
     Name = "lambda route table"
     Owner= var.owner
   }
 }


 #Create route table associations between subnets and route tables

 resource "aws_route_table_association" "rds_rt_association" {
   subnet_id = module.rds_subnet.subnet_id
   route_table_id = aws_route_table.rds_route_table.id
 }


resource "aws_route_table_association" "redshift_rt_association" {
   subnet_id = module.redshift_subnet.subnet_id
   route_table_id = aws_route_table.redshift_route_table.id
 }


resource "aws_route_table_association" "lambda_rt_association" {
   subnet_id = module.lambda_subnet.subnet_id
   route_table_id = aws_route_table.lambda_route_table.id
 }
