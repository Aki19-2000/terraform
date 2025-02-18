# variables.tf

variable "region" {
  default = "us-east-1"  # Changed to us-east-1
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  default     = "ami-085ad6ae776d8f09c"  # Replace with actual AMI ID
}
