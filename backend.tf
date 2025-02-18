terraform {
  backend "s3" {
    bucket         = "my-terraform-state"  # Replace with your S3 bucket name
    key            = "vpc-terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"       # Replace with your DynamoDB table name
  }
}
