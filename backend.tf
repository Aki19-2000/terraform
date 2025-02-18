# backend.tf

terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "vpc-terraform.tfstate"
    region         = "us-east-1"  # Changed to us-east-1
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}
