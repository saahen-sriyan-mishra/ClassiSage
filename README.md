[Terraform Plan.txt](https://github.com/user-attachments/files/17457764/Terraform.Plan.txt)[Terraform init.txt](https://github.com/user-attachments/files/17457734/Terraform.init.txt)# ClassiSage
A Machine Learning model made with AWS SageMaker and its Python SDK for Classification of HDFS Logs using Terraform for automation of infrastructure setup.


**Content**
- [Overview](#overview)
- [Getting Started](#getting-started-how-to-run-the-project)
- [Implementation Process](#implementation-process)
- [Output](#output)

### Overview
- The model is made with [AWS](https://aws.amazon.com/free/?gclid=Cj0KCQjwsc24BhDPARIsAFXqAB3yNI9ZauzphQ1GOonYTUXJYTKhYG55KwGHAYy6Lt8SZ-c9RjXTv0QaAtr3EALw_wcB&trk=14a4002d-4936-4343-8211-b5a150ca592b&sc_channel=ps&ef_id=Cj0KCQjwsc24BhDPARIsAFXqAB3yNI9ZauzphQ1GOonYTUXJYTKhYG55KwGHAYy6Lt8SZ-c9RjXTv0QaAtr3EALw_wcB:G:s&s_kwcid=AL!4422!3!453325184782!e!!g!!aws!10712784856!111477279771&all-free-tier.sort-by=item.additionalFields.SortRank&all-free-tier.sort-order=asc&awsf.Free%20Tier%20Types=*all&awsf.Free%20Tier%20Categories=*all) [SageMaker](https://aws.amazon.com/pm/sagemaker/?gclid=Cj0KCQjwsc24BhDPARIsAFXqAB36k5XVF3a7LCyuaYrqUK324FyKAjQvShNYyjQEGoPycm9gmHU7I_saAjyHEALw_wcB&trk=b5c1cff2-854a-4bc8-8b50-43b965ba0b13&sc_channel=ps&ef_id=Cj0KCQjwsc24BhDPARIsAFXqAB36k5XVF3a7LCyuaYrqUK324FyKAjQvShNYyjQEGoPycm9gmHU7I_saAjyHEALw_wcB:G:s&s_kwcid=AL!4422!3!532435768482!e!!g!!sagemaker!11539707798!109299504381) for Classification of [HDFS](http://hadoop.apache.org/hdfs) Logs along with [S3](https://aws.amazon.com/pm/serv-s3/?gclid=Cj0KCQjwsc24BhDPARIsAFXqAB1x3WFS-mpsRSyK5kwsOL07T6e8r5ZganmuBBahgeEjtuEtrCS66OoaAqZvEALw_wcB&trk=b8b87cd7-09b8-4229-a529-91943319b8f5&sc_channel=ps&ef_id=Cj0KCQjwsc24BhDPARIsAFXqAB1x3WFS-mpsRSyK5kwsOL07T6e8r5ZganmuBBahgeEjtuEtrCS66OoaAqZvEALw_wcB:G:s&s_kwcid=AL!4422!3!536397139414!p!!g!!amazon%20s3%20cloud%20storage!11539706604!115473954194) for storing dataset, Notebook file (containing code for SageMaker instance) and  Model Output.
- The Infrastructure setup is automated using [Terraform](https://www.terraform.io/) a tool to provide infrastructure-as-code created by [HashiCorp](https://www.hashicorp.com/)
- The data set used is [HDFS_v1](https://github.com/logpai/loghub).
- The project implements [SageMaker Python SDK](https://sagemaker.readthedocs.io/en/stable/?form=MG0AV3) with the model [XGBoost version 1.2](https://docs.aws.amazon.com/sagemaker/latest/dg/xgboost.html)

### Getting Started: How to Run the project
- Clone the repository using Git Bash / download a .zip file / fork the repository.
- Go to your AWS Management Console, click on your account profile on the Top-Right corner and select `My Security Credentials` from the dropdown.
- **Create Access Key:** In the Access keys section, click on Create New Access Key, a dialog will appear with your Access Key ID and Secret Access Key.
- **Download or Copy Keys:** (IMPORTANT) Download the .csv file or copy the keys to a secure location. This is the only time you can view the secret access key.
- Open the cloned Repo. in your VS Code
- Create a file under ClassiSage as terraform.tfvars with its content as

```hcl
# terraform.tfvars
access_key = "<YOUR_ACCESS_KEY>"
secret_key = "<YOUR_SECRET_KEY>"
aws_account_id = "<YOUR_AWS_ACCOUNT_ID>"
```

- Download and install all the dependancies for using Terraform and Python.
- In the terminal type/paste `terraform init` to initialize the backend.

```bash
Initializing the backend...
Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Reusing previous version of hashicorp/random from the dependency lock file
- Using previously-installed hashicorp/aws v5.70.0
- Using previously-installed hashicorp/random v3.6.3

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary
```

- Then type/paste `terraform Plan` to view the plan or simply `terraform validate` to ensure that there is no error.

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

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.]()
```
- Finally in the terminal type/paste `terraform apply --auto-approve`
- This will show two outputs one as bucket_name other as pretrained_ml_instance_name (The 3rd resource is the variable name given to the bucket since they are global resources ).

![0000](https://github.com/user-attachments/assets/d8d788a6-b8b8-4619-8999-c530625535cb)

- After Completion of the command is shown in the terminal, navigate to `ClassiSage/ml_ops/function.py` and on the 11th line of the file with code
```python
output = subprocess.check_output('terraform output -json', shell=True, cwd = r'<PATH_TO_THE_CLONED_FILE>' #C:\Users\Saahen\Desktop\ClassiSage
```
and change it to the path where the project directory is present and save it.
- Then on the `ClassiSage\ml_ops\data_upload.ipynb` run all code cell till cell number 25 with the code 
``` python
# Try to upload the local CSV file to the S3 bucket
try:
    print(f"try block executing")
    s3.upload_file(
        Filename=local_file_path, 
        Bucket=bucket_name,       
        Key=file_key               # S3 file key (filename in the bucket)
    )
    print(f"Successfully uploaded {file_key} to {bucket_name}")
    
    # Delete the local file after uploading to S3
    os.remove(local_file_path)
    print(f"Local file {local_file_path} deleted after upload.")
    
except Exception as e:
    print(f"Failed to upload file: {e}")
    os.remove(local_file_path)
```
 to upload dataset to S3 Bucket.
 ```
 ![fella](https://github.com/user-attachments/assets/887fefdd-d61b-4890-869b-74d858ddc926)
```
Output of the code cell execution
- After the execution of the notebook re-open your AWS Management Console.
- You can search for S3 and Sagemaker services and will see an instance of each service initiated (A S3 bucket and a SageMaker Notebook)
-------------------------------------------------------------------------------------------------
```
![1](https://github.com/user-attachments/assets/a3c177d8-6155-44b3-81f5-43b46e997548)
```
S3 Bucket with named 'data-bucket-<random_string>' with 2 objects uploaded, a dataset and the .ipynb file containing model code.
```
![2](https://github.com/user-attachments/assets/2b26d3f5-d955-4990-a0af-2eb7fe356ed7)
```
A SageMaker instance InService.
-------------------------------------------------------------------------------------------------
- Go to the notebook instance in the AWS SageMaker, click on the created instance and click on open Jupyter.
- After that click on `new` on the top right side of the window and select on `terminal`.
- This will create a new terminal.
- On the terminal paste the following (Replacing <Bucket-Name> with the bucket_name output that is shown in the VS Code's terminal output):
```bash
aws s3 cp s3://<Bucket-Name>/pretrained_sm.ipynb /home/ec2-user/SageMaker/
```
```
![3](https://github.com/user-attachments/assets/859bc4b6-2027-4e28-9ab7-cb9d521d499a)
```
Terminal command to upload the pretrained_sm.ipynb from S3 to Notebook's Jupyter environment
-------------------------------------------------------------------------------------------------
- Go Back to the opened Jupyter instance and click on the `pretrained_sm.ipynb` file to open it and assign it a `conda_python3` Kernel.
- Scroll Down to the 4th cell and replace the variable `bucket_name`'s value by the VS Code's terminal output for `bucket_name = "<bucket-name>"`
``` python
  # S3 bucket, region, session
bucket_name = 'data-bucket-axhq3rp8'
my_region = boto3.session.Session().region_name
sess = boto3.session.Session()
print("Region is " + my_region + " and bucket is " + bucket_name)
```
```
![el](https://github.com/user-attachments/assets/6517d028-f6a4-49f6-a01f-04ffdf0884a5)
```
Output of the code cell execution
-------------------------------------------------------------------------------------------------
- On the top of the file do a `Restart` by going to the Kernel tab.
- Execute the Notebook till code cell number 27, with the code 
``` python
# Print the metrics
print(f"Accuracy: {accuracy:.8f}")
print(f"Precision: {precision:.8f}")
print(f"Recall: {recall:.8f}")
print(f"F1 Score: {f1:.8f}")
print(f"False Positive Rate: {false_positive_rate:.8f}")
```
- You will get the intended result.

- **The data will be fetched, split into train and test sets after being adjusted for Labels and Features with a defined output path, then a model using SageMaker's Python SDK will be Trained, Deployed as a EndPoint, Validated to give different metrics.**  

-------------------------------------------------------------------------------------------------
**Console Observation Notes:**
- On execution of 8th cell with code
``` python
# Set an output path where the trained model will be saved
prefix = 'pretrained-algo'
output_path ='s3://{}/{}/output'.format(bucket_name, prefix)
print(output_path)
```
![x](https://github.com/user-attachments/assets/008e7340-d064-4f8a-b11c-c9d3e8470996)
![xx](https://github.com/user-attachments/assets/4f9384e7-4a45-4220-a903-c84750689c9a)

--------------------------------

an output path will be setup in the S3 to store model data.
- On execution of 23rd cell with code
``` python
estimator.fit({'train': s3_input_train,'validation': s3_input_test})
```
A training job will start, you can check it under the training tab.
![4](https://github.com/user-attachments/assets/7391e566-b6df-4a58-b381-116eca49ed84)

- After some time (3 mins est.) It shall be completed and will show the same.
![5](https://github.com/user-attachments/assets/313bd40d-9570-4b25-8dc1-86a9dc00b2a1)

- On execution of the code cell after that with code
``` python
xgb_predictor = estimator.deploy(initial_instance_count=1,instance_type='ml.m5.large')
```
an endpoint will be deployed under Inference tab.
![6](https://github.com/user-attachments/assets/e5ca8d0f-b626-4d10-ad98-950c9a05d0f1)


**Additional Console Observation:**
- Creation of an Endpoint Configuration under Inference tab.
![epc](https://github.com/user-attachments/assets/b2059605-bd80-4fff-a468-15a7c4834535)
- Creation of an model also under under Inference tab.
![model](https://github.com/user-attachments/assets/f863ee25-86ca-4c94-a77e-6836410f5cb2)

-------------------------------------------------------------------------------------------------
- In the VS Code comeback to data_upload.ipynb to execute last 2 code cells to download the S3 bucket's data into the local system.
- The folder will be named downloaded_bucket_content
![dbc](https://github.com/user-attachments/assets/28da4fb9-b533-4e3d-9521-22d9b2cd6b87)
Directory Structure of folder Downloaded.
-------------------------------------------------------------------------------------------------
**Model Observation Note:**

-------------------------------------------------------------------------------------------------

- You will get a log of downloaded files in the output cell. It will contain a raw pretrained_sm.ipynb, final_dataset.csv and a model output folder named 'pretrained-algo' with the execution data of the sagemaker code file.

- Come back to the VS Code terminal for the project file and then type/paste `terraform destroy --auto-approve`


- Finally go into pretrained_sm present inside the SageMaker instance and execute the final 2 code cells.
- **The end-point and the resources within the S3 bucket will be deleted to ensure no additional charges.**

### Implementation Process

### Output

**NOTE:** Auto Created Files  
ML-AWS/.terraform  
ML-AWS/ml_ops/__pycache  
ML-AWS/.terraform.lock.hcl  
ML-AWS/terraform.tfstate  
ML-AWS/terraform.tfstate.backup  
