# General Variables

variable "region" {
  description = "Default region for provider"
  type        = string
  default     = "us-east-1"
}

# Instance name
variable "instance_name" {
  description = "Name of ec2 instance"
  type        = string
}

# EC2 Variables

variable "ami" {
  description = "Amazon machine image to use for ec2 instance"
  type        = string
  default     = "ami-0574da719dca65348" # Ubuntu 22.04 LTS // us-east-1 free-tier eligible
}

variable "instance_type" {
  description = "ec2 instance type"
  type        = string
  default     = "t2.micro"
}

# Route 53 Variables

variable "domain" {
  description = "Domain for website"
  type        = string
}

# RDS Variables

variable "db_name" {
  description = "Name of DB"
  type        = string
}

variable "db_user" {
  description = "Username for DB"
  type        = string
}

variable "db_pass" {
  description = "Password for DB"
  type        = string
  sensitive   = true
}

