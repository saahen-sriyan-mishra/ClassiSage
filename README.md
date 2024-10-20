# ML AWS

- Clone the repository in Git Bash.
- Go to your AWS Management Console, click on your account profile on the Top-Right corner and select `My Security Credentials` from the dropdown.
- **Create Access Key:** In the Access keys section, click on Create New Access Key, a dialog will appear with your Access Key ID and Secret Access Key.
- **Download or Copy Keys:** IMPORTANT: Download the .csv file or copy the keys to a secure location. This is the only time you can view the secret access key.
- Open the cloned Repo. in your VS Code
- Create a file under ML-AWS as terraform.tfvars with content as

```hcl
# terraform.tfvars
access_key = "<YOUR_ACCESS_KEY>"
secret_key = "<YOUR_SECRET_KEY>"
aws_account_id = "<YOUR_AWS_ACCOUNT_ID>"
```
- Install the Dependancies for terraform and python in your 
- Do a `Save All` by going to Files.
- In the terminal type/paste `terraform init` to initialize the backend and then type/paste `terraform Plan` to view the plan.
- Finally in the terminal type/paste `terraform apply --auto-approve`
- This will show two outputs one as bucket_name other as pretrained_ml_instance_name.
- After Completion of the command in the terminal come to `ML-AWS/ml_ops/function.py` and on the 11th line of the file with code
```python
        output = subprocess.check_output('terraform output -json', shell=True, cwd = r'<PATH_TO_THE_CLONED_ML-AWS_FILE>'
```
and change it to your defined path and save it.
- Then do a `Run All` on the `ML-AWS\ml_ops\merged_&_cleaned_train_data_upload.ipynb` and after the completion of the execution of the entire notebook re-open your AWS Management Console.
- You can search for S3 an Sagemaker services and will see an instance of each service initiated (A S3 bucket and a SageMaker Notebook)
- Go to the notebook instance in the AWS SageMaker, click on the created instance and click on open Jupyter
- After that click on `new` on the top right side of the window and select on `terminal`
- This will create a new terminal
- On the terminal paste the following (Replacing <Bucket-Name> with the bucket_name output that is shown in the terminal output):
`aws s3 cp s3://<Bucket-Name>/pretrained_sm.ipynb /home/ec2-user/SageMaker/`
- Go Back to the opened Jupyter instance and click on the `pretrained_sm.ipynb` file to open it and assign it a `conda-python3` Kernel.
- Scroll Down to the 4th cell and replace the variable `bucket_name`'s value by the terminal output for `bucket_name = "<bucket-name>"`
- On the top of the file do a `Restart and Run All` by going to the Kernel tab. 
- You will get your Result.

**Auto Created Files**  
ML-AWS/.terraform  
ML-AWS/ml_ops/__pycache__  
ML-AWS/.terraform.lock.hcl  
ML-AWS/terraform.tfstate  
ML-AWS/terraform.tfstate.backup  
