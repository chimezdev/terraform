#first define your provider, search and download the source code for your preferred provider online. this defines the provider you want to use

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.48.0" #version is optional, u can remove this line
    }
  }
}

provider "aws" {
  region = "us-east-1"
  # Configuration options
}

resource "aws_instance" "my-first-ec2-using-tf" {
  ami           = "ami-0574da719dca65348" #goto to d ec2 console, deploy inst search for d ami u want e.g 'ubuntu' and copy
  instance_type = "t2.micro"

  tags = { #tag is optional
    Name = "first-inst-with-tf"
  }
}
