``` bash
Terraform used the selected providers to generate the following execution plan. Resource actions 
  + create

Terraform will perform the following actions:

  # module.s3.aws_s3_bucket.data_bucket will be created
  + resource "aws_s3_bucket" "data_bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_prefix               = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + policy                      = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags                        = {
          + "Environment" = "Dev"
          + "Name"        = "Data Bucket"
        }
      + tags_all                    = {
          + "Environment" = "Dev"
          + "Name"        = "Data Bucket"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + cors_rule (known after apply)

      + grant (known after apply)

      + lifecycle_rule (known after apply)

      + logging (known after apply)

      + object_lock_configuration (known after apply)

      + replication_configuration (known after apply)

      + server_side_encryption_configuration (known after apply)

      + versioning (known after apply)

      + website (known after apply)
    }

  # module.s3.random_string.unique_id will be created
  + resource "random_string" "unique_id" {
      + id          = (known after apply)
      + length      = 8
      + lower       = true
      + min_lower   = 0
      + min_numeric = 0
      + min_special = 0
      + min_upper   = 0
      + number      = true
      + numeric     = true
      + result      = (known after apply)
      + special     = false
      + upper       = false
    }

  # module.sagemaker.aws_s3_object.notebook_file will be created
  + resource "aws_s3_object" "notebook_file" {
      + acl                    = "private"
      + arn                    = (known after apply)
      + bucket                 = (known after apply)
      + bucket_key_enabled     = (known after apply)
      + checksum_crc32         = (known after apply)
      + checksum_crc32c        = (known after apply)
      + checksum_sha1          = (known after apply)
      + checksum_sha256        = (known after apply)
      + content_type           = (known after apply)
      + etag                   = (known after apply)
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "pretrained_sm.ipynb"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "aws_modules/sagemaker/../../ml_ops/pretrained_sm.ipynb"
      + storage_class          = (known after apply)
      + tags_all               = (known after apply)
      + version_id             = (known after apply)
    }

  # module.sagemaker.aws_sagemaker_notebook_instance.pretrained_ml_instance will be created
  + resource "aws_sagemaker_notebook_instance" "pretrained_ml_instance" {
      + arn                    = (known after apply)
      + direct_internet_access = "Enabled"
      + id                     = (known after apply)
      + instance_type          = "ml.t2.medium"
      + name                   = "pretrained-ml-instance"
      + network_interface_id   = (known after apply)
      + platform_identifier    = (known after apply)
      + role_arn               = "arn:aws:iam::730335575114:role/SageMakerExecutionRole"
      + root_access            = "Enabled"
      + security_groups        = (known after apply)
      + tags                   = {
          + "Environment" = "Dev"
          + "Name"        = "SageMaker Notebook Instance"
        }
      + tags_all               = {
    }

Plan: 4 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + bucket_name                 = (known after apply)
  + pretrained_ml_instance_name = "pretrained-ml-instance"

─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.     
```
