terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-unique"  # Name of the S3 bucket you just created
    key            = "state/terraform.tfstate"
    region         = "us-east-1"  # Use the region where your resources were created
    dynamodb_table = "my-terraform-lock-table"  # The name of the DynamoDB table you just created
    encrypt        = true
  }
}
