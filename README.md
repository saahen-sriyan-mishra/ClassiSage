# ClassiSage
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
- Go to your AWS Management Console, click on your account profile on the Top-Right corner and select `**My Security Credentials**` from the dropdown.
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
- In the terminal type/paste `terraform init` to initialize the backend and then type/paste `terraform Plan` to view the plan or simply `terraform validate` to ensure that there is no error.
- Finally in the terminal type/paste `terraform apply --auto-approve`
- This will show two outputs one as bucket_name other as pretrained_ml_instance_name (The 3rd resource is the variable name given to the bucket since they are global resources ).
- After Completion of the command in the terminal come to `ClassiSage/ml_ops/function.py` and on the 11th line of the file with code
```python
output = subprocess.check_output('terraform output -json', shell=True, cwd = r'<PATH_TO_THE_CLONED_FILE>'
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
- After the complete execution of the notebook re-open your AWS Management Console.
- You can search for S3 and Sagemaker services and will see an instance of each service initiated (A S3 bucket and a SageMaker Notebook)
- Go to the notebook instance in the AWS SageMaker, click on the created instance and click on open Jupyter.
- After that click on `new` on the top right side of the window and select on `terminal`.
- This will create a new terminal.
- On the terminal paste the following (Replacing <Bucket-Name> with the bucket_name output that is shown in the VS Code's terminal output):
```bash
aws s3 cp s3://<Bucket-Name>/pretrained_sm.ipynb /home/ec2-user/SageMaker/
```
- Go Back to the opened Jupyter instance and click on the `pretrained_sm.ipynb` file to open it and assign it a `conda-python3` Kernel.
- Scroll Down to the 4th cell and replace the variable `bucket_name`'s value by the VS Code's terminal output for `bucket_name = "<bucket-name>"`
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
that calculate the metrics.
- You will get the intended result.

- **The data will be fetched, split into train and test sets after being adjusted for Labels and Features with a defined output path, then a model using SageMaker's Python SDK will be Trained, Deployed as a EndPoint, Validated to give different metrics.**  
- In the VS Code comeback to data_upload.ipynb to execute last 2 code cells to download the S3 bucket's data into the local system.
- Finally go into pretrained_sm present inside the SageMaker instance and execute the final 2 code cells.
- **The end-point and the resources within the S3 bucket will be deleted to ensure no additional charges.**
- Come back to the VS Code terminal for the project file and then type/paste `terraform destroy --auto-approve`

### Implementation Process

### Output

**NOTE:** Auto Created Files  
ML-AWS/.terraform  
ML-AWS/ml_ops/__pycache  
ML-AWS/.terraform.lock.hcl  
ML-AWS/terraform.tfstate  
ML-AWS/terraform.tfstate.backup  
