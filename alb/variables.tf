variable "aws_region" {
  description = "The AWS region to deploy resources"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID to use for EC2 instances"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "vpc_id" {
  description = "VPC ID for the load balancer"
}

variable "subnet_ids" {
  description = "List of subnet IDs for the load balancer"
  type        = list(string)
}
