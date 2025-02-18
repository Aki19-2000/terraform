# Configure Terraform Backend.
terraform {
  backend "s3" {
    bucket         = "akired1"
    key            = "env:/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
  }
}
