terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.70.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }
}

## **NOTE**: Change the region as needed

provider "aws" {
  region     = "eu-west-3"
  access_key = var.access_key
  secret_key = var.secret_key
}

# Referencing S3 raw data upload 
module "s3" {
  source = "./aws_modules/s3"
}

# Import the SageMaker module and pass the bucket name
module "sagemaker" {
  source         = "./aws_modules/sagemaker"  # Adjust this path according to your file structure
  aws_account_id = var.aws_account_id
  bucket_name    = module.s3.bucket_name  # Pass the bucket name output from the S3 module
}

# Referencing RDS Module
module "rds" {
  source = "./aws_modules/rds"
}

