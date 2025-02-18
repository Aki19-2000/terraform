terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-unique"  # Use the actual name of your created S3 bucket
    key            = "state/terraform.tfstate"
    region         = "us-east-1"  # Same region as your S3 bucket and DynamoDB table
    dynamodb_table = "my-terraform-lock-table"  # Use the name of your created DynamoDB table
    encrypt        = true
  }
}
