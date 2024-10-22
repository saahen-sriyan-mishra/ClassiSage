/*# Needed for ARN ROLES
variable "aws_account_id" {
  description = "The AWS Account ID."
  type        = string
}

variable "bucket_name" {
  description = "The S3 bucket name."
  type        = string
}


# Create the SageMaker notebook instance
resource "aws_sagemaker_notebook_instance" "pretrained_ml_instance" {
  name           = "pretrained-ml-instance"
  instance_type  = "ml.t2.medium"
  role_arn       = "arn:aws:iam::${var.aws_account_id}:role/SageMakerExecutionRole"
  //lifecycle_configuration_name = aws_sagemaker_notebook_instance_lifecycle_configuration.eda_lifecycle.name

  tags = {
    Name        = "SageMaker Notebook Instance"
    Environment = "Dev"
  }
}

# Reference for output.tf to be able to access
output "pretrained_ml_instance_name" {
  value = aws_sagemaker_notebook_instance.pretrained_ml_instance.name  # Export the name of the SageMaker instance
}

# Use the bucket name for the S3 output path
locals {
  s3_output_path = "s3://${var.bucket_name}/output/"
}
*/


# Needed for ARN ROLES
variable "aws_account_id" {
  description = "The AWS Account ID."
  type        = string
}

variable "bucket_name" {
  description = "The S3 bucket name."
  type        = string
}

# Upload the notebook file to S3
resource "aws_s3_object" "notebook_file" {
  bucket = var.bucket_name  # Reference the S3 bucket passed as a variable (above function)
  key    = "pretrained_sm.ipynb"  # The name to give to the notebook file in S3
  source = "${path.module}/../../ml_ops/pretrained_sm.ipynb"  # Path to the notebook file
  acl    = "private"  # Set the appropriate ACL
}


# Create the SageMaker notebook instance
resource "aws_sagemaker_notebook_instance" "pretrained_ml_instance" {
  name          = "pretrained-ml-instance"
  instance_type = "ml.t2.medium"
  role_arn      = "arn:aws:iam::${var.aws_account_id}:role/SageMakerExecutionRole"
  tags = {
    Name        = "SageMaker Notebook Instance"
    Environment = "Dev"
  }
}

# Reference for output.tf to be able to access
output "pretrained_ml_instance_name" {
  value = aws_sagemaker_notebook_instance.pretrained_ml_instance.name  # Export the name of SageMaker instance
}

# Use the bucket name for the S3 output path
locals {
  s3_output_path = "s3://${var.bucket_name}/output/"
}
