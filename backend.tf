terraform {
  backend "s3" {
    bucket         = "my-terraform-state"  # Should match the S3 bucket you create
    key            = "vpc-terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"       # Should match the DynamoDB table you create
  }
}
