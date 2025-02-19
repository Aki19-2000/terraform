variable "aws_region" {
  description = "The AWS region to deploy resources"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID to use for EC2 instances"
  default     = "ami-085ad6ae776d8f09c"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

