terraform {
  backend "s3" {
    bucket         = "greeny-terraform-up-and-running" 
    key            = "eu-north-1/state-files/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-lock-table" # For state locking
    encrypt        = true
  }
}

# create the versiooned bucket manually via the console, then run terraform init 
#so this file is used to initialize the created bucket as terraform statefile