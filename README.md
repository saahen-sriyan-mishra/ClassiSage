# ClassiSage
![Build Status](https://img.shields.io/badge/build-3.6-Yellow)

A Machine Learning model made with AWS SageMaker and its Python SDK for Classification of HDFS Logs using Terraform for automation of infrastructure setup.


## **Content**
- [Overview](#overview): Project Overview.
- [System Architecture](#system-architecture): System Architecture Diagram
- [ML Model](#ml-model): Model Overview.
- [Getting Started](#getting-started): How to run the project.
- [Console Observations](#console-observation-notes): Changes in instances and infrastructure that can be observed while running the project.
- [Ending and Cleanup](#ending-and-cleanup): Ensuring no additional charges.
- [Auto Created Objects](#auto-created-objects): Files and Folders created during execution process.

## Overview
- The model is made with [AWS](https://aws.amazon.com/free/?gclid=Cj0KCQjwsc24BhDPARIsAFXqAB3yNI9ZauzphQ1GOonYTUXJYTKhYG55KwGHAYy6Lt8SZ-c9RjXTv0QaAtr3EALw_wcB&trk=14a4002d-4936-4343-8211-b5a150ca592b&sc_channel=ps&ef_id=Cj0KCQjwsc24BhDPARIsAFXqAB3yNI9ZauzphQ1GOonYTUXJYTKhYG55KwGHAYy6Lt8SZ-c9RjXTv0QaAtr3EALw_wcB:G:s&s_kwcid=AL!4422!3!453325184782!e!!g!!aws!10712784856!111477279771&all-free-tier.sort-by=item.additionalFields.SortRank&all-free-tier.sort-order=asc&awsf.Free%20Tier%20Types=*all&awsf.Free%20Tier%20Categories=*all) [SageMaker](https://aws.amazon.com/pm/sagemaker/?gclid=Cj0KCQjwsc24BhDPARIsAFXqAB36k5XVF3a7LCyuaYrqUK324FyKAjQvShNYyjQEGoPycm9gmHU7I_saAjyHEALw_wcB&trk=b5c1cff2-854a-4bc8-8b50-43b965ba0b13&sc_channel=ps&ef_id=Cj0KCQjwsc24BhDPARIsAFXqAB36k5XVF3a7LCyuaYrqUK324FyKAjQvShNYyjQEGoPycm9gmHU7I_saAjyHEALw_wcB:G:s&s_kwcid=AL!4422!3!532435768482!e!!g!!sagemaker!11539707798!109299504381) for Classification of [HDFS](http://hadoop.apache.org/hdfs) Logs along with [S3](https://aws.amazon.com/pm/serv-s3/?gclid=Cj0KCQjwsc24BhDPARIsAFXqAB1x3WFS-mpsRSyK5kwsOL07T6e8r5ZganmuBBahgeEjtuEtrCS66OoaAqZvEALw_wcB&trk=b8b87cd7-09b8-4229-a529-91943319b8f5&sc_channel=ps&ef_id=Cj0KCQjwsc24BhDPARIsAFXqAB1x3WFS-mpsRSyK5kwsOL07T6e8r5ZganmuBBahgeEjtuEtrCS66OoaAqZvEALw_wcB:G:s&s_kwcid=AL!4422!3!536397139414!p!!g!!amazon%20s3%20cloud%20storage!11539706604!115473954194) for storing dataset, Notebook file (containing code for SageMaker instance) and  Model Output.
- The Infrastructure setup is automated using [Terraform](https://www.terraform.io/) a tool to provide infrastructure-as-code created by [HashiCorp](https://www.hashicorp.com/)
- The data set used is [HDFS_v1](https://github.com/logpai/loghub).
- The project implements [SageMaker Python SDK](https://sagemaker.readthedocs.io/en/stable/?form=MG0AV3) with the model [XGBoost version 1.2](https://docs.aws.amazon.com/sagemaker/latest/dg/xgboost.html)

--------------------------------------------------
## System Architecture

![![System_Arch_Diagram_Terraform](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/Untitled%20design.png)](https://github.com/user-attachments/assets/1d9be0ac-89a1-499d-9622-9e86e286da7d)
## ML Model
- Image URI
  ``` python
  # Looks for the XGBoost image URI and builds an XGBoost container. Specify the repo_version depending on preference.
  container = get_image_uri(boto3.Session().region_name,
                            'xgboost', 
                            repo_version='1.0-1')
  ```
  ![a](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/a.jpg)

- **Initializing Hyper Parameter and Estimator call to the container**
  ``` python
  hyperparameters = {
        "max_depth":"5",                ## Maximum depth of a tree. Higher means more complex models but risk of overfitting.
        "eta":"0.2",                    ## Learning rate. Lower values make the learning process slower but more precise.
        "gamma":"4",                    ## Minimum loss reduction required to make a further partition on a leaf node. Controls the model’s complexity.
        "min_child_weight":"6",         ## Minimum sum of instance weight (hessian) needed in a child. Higher values prevent overfitting.
        "subsample":"0.7",              ## Fraction of training data used. Reduces overfitting by sampling part of the data. 
        "objective":"binary:logistic",  ## Specifies the learning task and corresponding objective. binary:logistic is for binary classification.
        "num_round":50                  ## Number of boosting rounds, essentially how many times the model is trained.
        }
  # A SageMaker estimator that calls the xgboost-container
  estimator = sagemaker.estimator.Estimator(image_uri=container,                  # Points to the XGBoost container we previously set up. This tells SageMaker which algorithm container to use.
                                          hyperparameters=hyperparameters,      # Passes the defined hyperparameters to the estimator. These are the settings that guide the training process.
                                          role=sagemaker.get_execution_role(),  # Specifies the IAM role that SageMaker assumes during the training job. This role allows access to AWS resources like S3.
                                          train_instance_count=1,               # Sets the number of training instances. Here, it’s using a single instance.
                                          train_instance_type='ml.m5.large',    # Specifies the type of instance to use for training. ml.m5.2xlarge is a general-purpose instance with a balance of compute, memory, and network resources.
                                          train_volume_size=5, # 5GB            # Sets the size of the storage volume attached to the training instance, in GB. Here, it’s 5 GB.
                                          output_path=output_path,              # Defines where the model artifacts and output of the training job will be saved in S3.
                                          train_use_spot_instances=True,        # Utilizes spot instances for training, which can be significantly cheaper than on-demand instances. Spot instances are spare EC2 capacity offered at a lower price.
                                          train_max_run=300,                    # Specifies the maximum runtime for the training job in seconds. Here, it's 300 seconds (5 minutes).
                                          train_max_wait=600)                   # Sets the maximum time to wait for the job to complete, including the time waiting for spot instances, in seconds. Here, it's 600 seconds (10 minutes).
  ```
  ![b](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/b.jpg)

- **Training Job**

  ``` python
  estimator.fit({'train': s3_input_train,'validation': s3_input_test})
  ```
  ![c](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/c.jpg)

- **Deployment**
  ``` python
  xgb_predictor = estimator.deploy(initial_instance_count=1,instance_type='ml.m5.large')
  ```
  ![d](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/d.jpg)

- **Validation**
  ``` python
  from sagemaker.serializers import CSVSerializer
  import numpy as np
  from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, confusion_matrix

  # Drop the label column from the test data
  test_data_features = test_data_final.drop(columns=['Label']).values

  # Set the content type and serializer
  xgb_predictor.serializer = CSVSerializer()
  xgb_predictor.content_type = 'text/csv'

  # Perform prediction
  predictions = xgb_predictor.predict(test_data_features).decode('utf-8')

  y_test = test_data_final['Label'].values

  # Convert the predictions into a array
  predictions_array = np.fromstring(predictions, sep=',')
  print(predictions_array.shape)

  # Converting predictions them to binary (0 or 1)
  threshold = 0.5
  binary_predictions = (predictions_array >= threshold).astype(int)

  # Accuracy
  accuracy = accuracy_score(y_test, binary_predictions)

  # Precision
  precision = precision_score(y_test, binary_predictions)

  # Recall
  recall = recall_score(y_test, binary_predictions)

  # F1 Score
  f1 = f1_score(y_test, binary_predictions)

  # Confusion Matrix
  cm = confusion_matrix(y_test, binary_predictions)

  # False Positive Rate (FPR) using the confusion matrix
  tn, fp, fn, tp = cm.ravel()
  false_positive_rate = fp / (fp + tn)

  # Print the metrics
  print(f"Accuracy: {accuracy:.8f}")
  print(f"Precision: {precision:.8f}")
  print(f"Recall: {recall:.8f}")
  print(f"F1 Score: {f1:.8f}")
  print(f"False Positive Rate: {false_positive_rate:.8f}")
  ```
  ![e](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/e.jpg)

## Getting Started
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
- In the terminal type/paste [`terraform init`](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/Terraform%20init.md) to initialize the backend.

- Then type/paste [`terraform Plan`](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/Terraform%20Plan.md) to view the plan or simply `terraform validate` to ensure that there is no error.

- Finally in the terminal type/paste `terraform apply --auto-approve`
- This will show two outputs one as bucket_name other as pretrained_ml_instance_name (The 3rd resource is the variable name given to the bucket since they are global resources ).

  ![0000](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/0000.jpg)

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

- **Output of the code cell execution**

  ![fella](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/fella.jpg)

- After the execution of the notebook re-open your AWS Management Console.
- You can search for S3 and Sagemaker services and will see an instance of each service initiated (A S3 bucket and a SageMaker Notebook)
 
 **S3 Bucket with named 'data-bucket-<random_string>' with 2 objects uploaded, a dataset and the pretrained_sm.ipynb file containing model code.**
  ![1](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/1.jpg)

  **A SageMaker instance InService.**
  ![2](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/2.jpg)

-------------------------------------------------------------------------------------------------
- Go to the notebook instance in the AWS SageMaker, click on the created instance and click on open Jupyter.
- After that click on `new` on the top right side of the window and select on `terminal`.
- This will create a new terminal.

-------------------------------------------------------------------------------------------------
- On the terminal paste the following (Replacing <Bucket-Name> with the bucket_name output that is shown in the VS Code's terminal output):
  ```bash
  aws s3 cp s3://<Bucket-Name>/pretrained_sm.ipynb /home/ec2-user/SageMaker/
  ```
  **Terminal command to upload the pretrained_sm.ipynb from S3 to Notebook's Jupyter environment**
  ![3](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/3.jpg)

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

  **Output of the code cell execution**

  ![el](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/el.jpg)

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
## Console Observation Notes
**Execution of 8th cell**
``` python
# Set an output path where the trained model will be saved
prefix = 'pretrained-algo'
output_path ='s3://{}/{}/output'.format(bucket_name, prefix)
print(output_path)
```
- An output path will be setup in the S3 to store model data.
![x](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/x.jpg)
![xx](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/xx.jpg)


**Execution of 23rd cell**
``` python
estimator.fit({'train': s3_input_train,'validation': s3_input_test})
```

- A training job will start, you can check it under the training tab.
![4](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/4.jpg)
- After some time (3 mins est.) It shall be completed and will show the same.
![5](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/5.jpg)

**Execution of 24th code cell**
``` python
xgb_predictor = estimator.deploy(initial_instance_count=1,instance_type='ml.m5.large')
```
- An endpoint will be deployed under Inference tab.
![6](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/6.jpg)

**Additional Console Observation:**
- Creation of an Endpoint Configuration under Inference tab.
![epc](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/epc.jpg)
- Creation of an model also under under Inference tab.
![model](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/model.jpg)

-------------------------------------------------------------------------------------------------
## Ending and Cleanup
- In the VS Code comeback to data_upload.ipynb to execute last 2 code cells to download the S3 bucket's data into the local system.
- The folder will be named downloaded_bucket_content.
  **Directory Structure of folder Downloaded.**
  ![dbc](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/dbc.jpg)

- You will get a log of downloaded files in the output cell. It will contain a raw pretrained_sm.ipynb, final_dataset.csv and a model output folder named 'pretrained-algo' with the execution data of the sagemaker code file.
- Finally go into pretrained_sm.ipynb present inside the SageMaker instance and execute the final 2 code cells.
**The end-point and the resources within the S3 bucket will be deleted to ensure no additional charges.**
- Deleting The EndPoint
  ``` python
  sagemaker.Session().delete_endpoint(xgb_predictor.endpoint)
  ```
  ![f](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/f.jpg)

- Clearing S3: (Needed to destroy the instance)
  ``` python
  bucket_to_delete = boto3.resource('s3').Bucket(bucket_name)
  bucket_to_delete.objects.all().delete()
  ```
  ![g](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/g.jpg)

- Come back to the VS Code terminal for the project file and then type/paste `terraform destroy --auto-approve`
- All the created resource instances will be deleted.

## Auto Created Objects
ClassiSage/downloaded_bucket_content
ClassiSage/.terraform  
ClassiSage/ml_ops/__pycache  
ClassiSage/.terraform.lock.hcl  
ClassiSage/terraform.tfstate  
ClassiSage/terraform.tfstate.backup  
