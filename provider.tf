terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.48.0"
    }
  }
  backend "s3" {
    bucket         = "remote-srikanth-90s"
    key            = "vpc-practice.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true # Enables native S3 state locking (Terraform 1.10+)
  }
}



# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}




 