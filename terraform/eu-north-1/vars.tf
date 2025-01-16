variable "owner"{
    default = "Analytics team"
    }


variable "vpc_name"{
    default = "Greeny VPC"
}


variable "s3_bucket" {
  description = "S3 bucket name where data will be uploaded"
  type        = string
  default = "greeny-pharma-datalake"
}


variable "redshift_db_password" {
  description = "password for redshift database"
  type        = string
  default = "yourpassword"
}


variable "db_password" {
  description = "Password for the PostgreSQL database"
  type        = string
  sensitive   = true
  default = "yourpassword"
}