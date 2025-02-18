# Create an S3 bucket for Terraform state management
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-terraform-state-bucket-unique"  # Ensure this is a globally unique name
  acl    = "private"
  region = "us-east-1"  # Change this to your desired region
}

# Create a DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "my-terraform-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  region = "us-east-1"  # Same region as your S3 bucket
}
