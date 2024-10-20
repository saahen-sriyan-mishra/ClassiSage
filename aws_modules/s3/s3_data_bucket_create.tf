# (RESOURCE 1)
# For my bucket not taken
resource "random_string" "unique_id" {
  length  = 8
  special = false
  upper   = false  # Ensure only lowercase letters are used
}


# (RESOURCE 2)
# create bucket
resource "aws_s3_bucket" "data_bucket" {
  bucket = "data-bucket-${random_string.unique_id.result}"
  
  tags   = {
    Name        = "Data Bucket"
    Environment = "Dev"
  }
}


output "bucket_name" {
  value = aws_s3_bucket.data_bucket.id 
}
