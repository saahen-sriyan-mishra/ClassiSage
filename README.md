# ClassiSage
A Machine Learning model made with AWS SageMaker and its Python SDK for Classification of HDFS Logs using Terraform for automation of infrastructure setup.

## Getting Started 
- Clone the repository using Git Bash / download a .zip file / fork the repository.
- Go to your AWS Management Console, click on your account profile on the Top-Right corner and select `My Security Credentials` from the dropdown.
- **Create Access Key:** In the Access keys section, click on Create New Access Key, a dialog will appear with your Access Key ID and Secret Access Key.
- **Download or Copy Keys:** IMPORTANT: Download the .csv file or copy the keys to a secure location. This is the only time you can view the secret access key.
- Open the cloned Repo. in your VS Code
- Create a file under ClassiSage as terraform.tfvars with its content as

```hcl
# terraform.tfvars
access_key = "<YOUR_ACCESS_KEY>"
secret_key = "<YOUR_SECRET_KEY>"
aws_account_id = "<YOUR_AWS_ACCOUNT_ID>"
```
- Download and install all the dependancies for using Terraform and Python.
- In the terminal type/paste `terraform init` to initialize the backend and then type/paste `terraform Plan` to view the plan.
- Finally in the terminal type/paste `terraform apply --auto-approve`
- This will show two outputs one as bucket_name other as pretrained_ml_instance_name (The 3rd resource is the variable name given to the bucket since they are global resources ).
- After Completion of the command in the terminal come to `ML-AWS/ml_ops/function.py` and on the 11th line of the file with code
```python
        output = subprocess.check_output('terraform output -json', shell=True, cwd = r'<PATH_TO_THE_CLONED_FILE>'
```
and change it to the path where the project directory is present and save it.
- Then do a `Run All` on the `ML-AWS\ml_ops\merged_&_cleaned_train_data_upload.ipynb` and after the completion of the execution of the entire notebook re-open your AWS Management Console.
- You can search for S3 and Sagemaker services and will see an instance of each service initiated (A S3 bucket and a SageMaker Notebook)
- Go to the notebook instance in the AWS SageMaker, click on the created instance and click on open Jupyter.
- After that click on `new` on the top right side of the window and select on `terminal`.
- This will create a new terminal.
- On the terminal paste the following (Replacing <Bucket-Name> with the bucket_name output that is shown in the VS Code's terminal output):
`aws s3 cp s3://<Bucket-Name>/pretrained_sm.ipynb /home/ec2-user/SageMaker/`
- Go Back to the opened Jupyter instance and click on the `pretrained_sm.ipynb` file to open it and assign it a `conda-python3` Kernel.
- Scroll Down to the 4th cell and replace the variable `bucket_name`'s value by the VS Code's terminal output for `bucket_name = "<bucket-name>"`
- On the top of the file do a `Restart and Run All` by going to the Kernel tab. 
- You will get your result i.e the data will be fetched, split into train and test sets after being adjusted for Labels and Features with a defined output path, then a model using SageMaker's Python SDK will be Trained, Deployed as a EndPoint, Validated to give different metrics. Finally the end-point and the resources within the S3 bucket will be deleted so ensure no additional charges.

**NOTE:** Auto Created Files  
ML-AWS/.terraform  
ML-AWS/ml_ops/__pycache  
ML-AWS/.terraform.lock.hcl  
ML-AWS/terraform.tfstate  
ML-AWS/terraform.tfstate.backup  
