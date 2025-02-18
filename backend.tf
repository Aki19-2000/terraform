terraform {
  backend "s3" {
    bucket = "akired-${random_string.bucket_suffix.result}"
    key    = "terraform.tfstate"
    region = "us-east-1"  # Ensure this matches your intended region
    encrypt = true
  }
}
