# explicite reference to the s3 module,

# since i want the s3_raw_data_upload.tf's s3 bucket name output accessable to my main config.
# Output the bucket name from the S3 module
output "bucket_name" {
  value = module.s3.bucket_name
}

# Output the SageMaker instance name
output "pretrained_ml_instance_name" {
  value = module.sagemaker.pretrained_ml_instance_name
}

# Output the RDS instance name
output "rds_db_name" {
  value = module.rds.db_name
  description = "The name of the RDS database instance"
}

