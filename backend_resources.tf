# Create the S3 Bucket for Terraform State
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-terraform-state"  # Make sure the bucket name is globally unique

  versioning {
    enabled = true
  }

  tags = {
    Name        = "terraform-state"
    Environment = "dev"
  }
}

# Create DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_lock" {
  name           = "terraform-lock"  # Table name for Terraform lock
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "terraform-lock"
    Environment = "dev"
  }
}
