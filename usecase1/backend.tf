# Configure Terraform Backend.
terraform {
  backend "s3" {
    bucket         = "nsh-usecase1"
    key            = "env:/dev/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
  }
}
