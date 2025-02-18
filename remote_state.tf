terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-unique"  # Ensure this is a globally unique name
    key            = "state/terraform.tfstate"
    region         = "eu-west-3"  # Set this to the correct region where your resources are located
    dynamodb_table = "my-terraform-lock-table"  # Ensure this matches the region as well
    encrypt        = true
  }
}
