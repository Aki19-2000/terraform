resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-terraform-state-bucket-unique"  # Ensure this is a globally unique name
  acl    = "private"
}

resource "aws_dynamodb_table" "terraform_lock" {
  name         = "my-terraform-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
