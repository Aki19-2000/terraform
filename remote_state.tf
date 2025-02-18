# Create an S3 bucket for Terraform state management
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-terraform-state-bucket-unique"  # Make sure to use a unique name for your S3 bucket
  acl    = "private"
  region = "us-east-1"  # Make sure to use the desired region
}

# Create a DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "my-terraform-lock-table"  # Name for your lock table
  billing_mode = "PAY_PER_REQUEST"

  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }

  region = "us-east-1"  # DynamoDB table in the same region as your S3 bucket
}

# Configure the Terraform backend to use the S3 bucket and DynamoDB table
terraform {
  backend "s3" {
    bucket         = aws_s3_bucket.terraform_state.bucket
    key            = "state/terraform.tfstate"
    region         = "us-east-1"  # Ensure the region matches the S3 bucket and DynamoDB table
    dynamodb_table = aws_dynamodb_table.terraform_lock.name
    encrypt        = true
  }
}
