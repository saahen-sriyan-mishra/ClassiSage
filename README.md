# ClassiSage
![Build Status](https://img.shields.io/badge/Build-3.6-Yellow) ![AWS](https://img.shields.io/badge/AWS-SageMaker,_S3-Blue) ![IaC](https://img.shields.io/badge/IaC-Terraform-Blue)

A Machine Learning model made with AWS SageMaker and its Python SDK for Classification of HDFS Logs using Terraform for automation of infrastructure setup.

Link: [DEV Blog](https://dev.to/saahen_sriyan_mishra/classisage-terraform-iac-automated-aws-sagemaker-based-hdfs-log-classification-model-4pk4)

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

![System_Architecture_Diagram_Terraform](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/System_Arch_Diagram_Terraform.png)
## ML Model
- Image URI
(Old Version): Specify the repo_version depending on preference.
  ``` python
  # Looks for the XGBoost image URI and builds an XGBoost container.
  container = get_image_uri(boto3.Session().region_name,
                            'xgboost', 
                            repo_version='1.0-1')
  ```
- Image URI (Updated Version)
  ``` python
  container = sagemaker.image_uris.retrieve(framework='xgboost', 
                                          region=boto3.Session().region_name, 
                                          version='1.0-1')
  ```
  ![Get Image method execution](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/a.jpg)

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
  ![Estimator instance to call image](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/b.jpg)

- **Training Job**

  ``` python
  estimator.fit({'train': s3_input_train,'validation': s3_input_test})
  ```
  ![Training Job Execution](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/c.jpg)

- **Deployment**
  ``` python
  xgb_predictor = estimator.deploy(initial_instance_count=1,instance_type='ml.m5.large')
  ```
  ![Endpoint Deployment/Hosting](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/d.jpg)

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
  ![Validation metrics(ACC, Precision, Recall, F1, False +ve rate)](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/e.jpg)

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

  ![Terminal Output of Terraform Apply](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/0000.jpg)

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

  ![Execution of upload function's try block](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/fella.jpg)

- After the execution of the notebook re-open your AWS Management Console.
- You can search for S3 and Sagemaker services and will see an instance of each service initiated (A S3 bucket and a SageMaker Notebook)
 
 **S3 Bucket with named 'data-bucket-<random_string>' with 2 objects uploaded, a dataset and the pretrained_sm.ipynb file containing model code.**
  ![Created databucket with dataset and .ipynb file](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/1.jpg)

  **A SageMaker instance InService.**
  ![Created sagemaker notebook instance](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/2.jpg)

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
  ![Terminal command downloading the .ipynb file from S3 to Notebook env inside Jupyter](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/3.jpg)

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

  ![Region and bucket name in sagemaker notebook](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/el.jpg)

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
![Output path folder added to S3](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/x.jpg)
![Folders loaded nto the path after execution](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/xx.jpg)


**Execution of 23rd cell**
``` python
estimator.fit({'train': s3_input_train,'validation': s3_input_test})
```

- A training job will start, you can check it under the training tab.
![Training Job InProgress](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/4.jpg)
- After some time (3 mins est.) It shall be completed and will show the same.
![Training Job Completed](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/5.jpg)

**Execution of 24th code cell**
``` python
xgb_predictor = estimator.deploy(initial_instance_count=1,instance_type='ml.m5.large')
```
- An endpoint will be deployed under Inference tab.
![Deployed Endpoint](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/6.png)

**Additional Console Observation:**
- Creation of an Endpoint Configuration under Inference tab.
![Endpoint config](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/epc.png)
- Creation of an model also under under Inference tab.
![model](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/model.png)

-------------------------------------------------------------------------------------------------
## Ending and Cleanup
- In the VS Code comeback to data_upload.ipynb to execute last 2 code cells to download the S3 bucket's data into the local system.
- The folder will be named downloaded_bucket_content.
  **Directory Structure of folder Downloaded.**
  ![downloaded bucket content](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/dbc.jpg)

- You will get a log of downloaded files in the output cell. It will contain a raw pretrained_sm.ipynb, final_dataset.csv and a model output folder named 'pretrained-algo' with the execution data of the sagemaker code file.
- Finally go into pretrained_sm.ipynb present inside the SageMaker instance and execute the final 2 code cells.
**The end-point and the resources within the S3 bucket will be deleted to ensure no additional charges.**
- Deleting The EndPoint
  ``` python
  sagemaker.Session().delete_endpoint(xgb_predictor.endpoint)
  ```
  ![EndPoint Deletion](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/f.jpg)

- Clearing S3: (Needed to destroy the instance)
  ``` python
  bucket_to_delete = boto3.resource('s3').Bucket(bucket_name)
  bucket_to_delete.objects.all().delete()
  ```
  ![Deleting All objects in S3](https://github.com/saahen-sriyan-mishra/ClassiSage/blob/main/MD%20Scr/g.jpg)

- Come back to the VS Code terminal for the project file and then type/paste `terraform destroy --auto-approve`
- All the created resource instances will be deleted.

## Auto Created Objects
ClassiSage/downloaded_bucket_content
ClassiSage/.terraform  
ClassiSage/ml_ops/__pycache  
ClassiSage/.terraform.lock.hcl  
ClassiSage/terraform.tfstate  
ClassiSage/terraform.tfstate.backup  












Optimizing Urban Mobility: A Comprehensive Approach to Dynamic Traffic Flow Management

Suvankar Dash

School of Computer Engineering KIIT University

Bhubaneswar, Odisha
suvankardash0103@gmail.com

Rahul Biswas

School of Electronics Engineering KIIT University

Bhubaneswar, Odisha biswasrahul016@gmail.com

Shashank Dewangan
School of Computer Engineering KIIT University

Bhubaneswar, Odisha shasnk2267@gmail.com

Subhashree Mishra
School of Electronics Engineering KIIT University

Bhubaneswar, Odisha
subhashree.mishrafet@kiit.ac.in

Bhabani Shankar Prasad Mishra School of Computer Engineering KIIT University

Bhubaneswar, Odisha bsmishrafcs@kiit.ac.in

Saahen Sriyan Mishra
School of Computer Engineering KIIT University

Bhubaneswar, Odisha saahenmishra@gmail.com

Abstract—This study describes a novel dynamic traffic flow management system built for urban intersections to improve vehicle navigation and control. Using YOLOv8 for real-time vehicle recognition and categorization, the system efficiently prioritises emergency vehicles. Integration with the Easy-OCR Object Detection model makes number plate detection easier, and subsequent verification against the National Informatics Centre (NIC) database ensures conformity to emergency requirements. Advanced routing algorithms (A\*, Dijkstra’s, and BFS) are used to optimise network flows and reduce congestion globally, regardless of external mapping services such as Google Maps. This self-sufficient system demonstrates a scalable and secure solution to current traffic management.

Index Terms—YOLOv8, EasyOCR, IoT, V2V/V2I, A\*, Dijk- stra, CNN, Path-Finding.

1. INTRODUCTION

Urban traffic management is undergoing a crucial transfor- mation from traditional static systems to dynamic, intelligent models due to the escalating demands and complexities asso- ciated with growing urban populations. This shift is primarily driven by the integration of Artificial Intelligence (AI) and Machine Learning (ML), which offer sophisticated tools to en- hance the efficiency and safety of vehicular navigation across various traffic scenarios. As cities worldwide face challenges such as increasing congestion, pollution, and infrastructural demands, AI applications in traffic systems emerge as vital solutions to these issues as visualised in Fig 1. AI and ML are harnessed to develop adaptive traffic manage- ment systems that leverage real-time data and advanced analyt- ics to respond promptly to fluctuating traffic conditions. These technologies not only aim to improve traffic flow and road safety but also present a significant evolution over conventional traffic management approaches. For example, contemporary AI-enabled traffic systems utilize extensive sensor and camera networks embedded within urban infrastructures to adjust traffic signals dynamically and predict potential bottlenecks before they lead to congestion [2].

Furthermore, the application of advanced deep learning models such as Convolutional Neural Networks (CNN’s) and Recur- rent Neural Networks (RNNs) facilitates the automated detec- tion and classification of vehicles. This capability is essential for implementing priority-based traffic controls, allowing for the differentiation between emergency and regular vehicles to streamline traffic flow efficiently. The integration of YOLOv8, a state-of-the-art object detection system, exemplifies this innovative approach by enhancing the accuracy and speed of vehicle detection, which is crucial for the operational success of real-time traffic management systems [3].

The synergy between ML and the Internet of Things (IoT) significantly augments the effectiveness of traffic management systems. This integration enables the continuous and compre- hensive monitoring of traffic conditions, thereby supporting sophisticated models that proactively adjust traffic controls based on predictive traffic volume analyses [1].

However, the adoption of these advanced technologies is not without challenges. Issues such as ensuring data privacy, secur- ing networks, and addressing potential biases in AI algorithms are paramount to the ethical application of these technologies in public domains. Moreover, these systems require ongoing adaptation and fine-tuning to meet the unique and evolving needs of urban traffic environments.

Looking forward, the role of AI in traffic management is set to increase, driven by technological advancements and a heightened focus on sustainable urban development. Continued research and development in this field are essential to address existing limitations and fully realize the potential of AI- enhanced traffic management systems. With diligent devel- opment and strategic implementation, AI-driven solutions are poised to transform urban mobility, making it more efficient, safer, and better suited to the demands of modern cities.

![](Aspose.Words.c202e6b7-bb2d-4c8f-bbe5-d51365998a2b.001.png)

Fig. 1: Physical Visualization/Simulation of Smart V2I com- munications

2. PROBLEM STATEMENT

Urban traffic congestion poses a formidable challenge, severely disrupting vehicular flow and, crucially, the opera- tional efficiency of emergency services. Conventional traffic management systems, characterized by their static and rigid frameworks, are ill-equipped to meet the dynamic demands of contemporary urban environments. These systems frequently fail to prioritize vehicles strategically based on urgency, exac- erbating congestion during peak traffic periods and emergency situations. Such inefficiencies critically delay emergency re- sponse times, underscoring the urgent need for an adaptive traffic management solution.

This project proposes a focused initiative to refine traffic flow specifically for emergency vehicles. By prioritizing this segment, the project aims to develop and test innovative traffic management methodologies and technologies that can subsequently be adapted to broader applications. This strate- gic approach not only seeks to enhance the efficiency of emergency responses but also serves as a foundational model for comprehensive traffic system overhauls. The successful implementation and validation of this system are anticipated to offer substantial improvements in managing urban traffic flows, thereby serving as a pivotal proof of concept for scalable traffic management solutions.

This targeted initiative provides a pragmatic and impactful entry point for demonstrating the capabilities of advanced traffic management systems, with the potential for extensive applicability in enhancing general urban mobility. As such, it aligns with the current research and development trajectories in smart urban infrastructure, offering significant contributions to the fields of traffic engineering and urban planning. The findings from this project are expected to catalyze further innovations and foster broader implementations of intelligent traffic management systems globally.

A. Project Planning Phases

The project planning adheres to a rigorous and structured methodology, aimed at ensuring the successful deployment of an advanced intelligent traffic management system. Each component of the project is carefully defined and executed to meet the sophisticated demands of modern urban traffic systems:

1) Requirement Identification: Central to this project is

the goal of enhancing urban traffic management through the implementation of Vehicle-to-Infrastructure (V2I) communi- cation technologies. The immediate focus of this initiative is the development of software capabilities specifically designed for the detection and rerouting of emergency vehicles. This focused approach facilitates the intensive development and testing of key functionalities critical for optimizing emergency response efficiency across urban landscapes.

2) Objective Formulation: The principal objective of this

initial phase is to engineer and rigorously validate a software framework that supports the precise detection and strategic rerouting of emergency vehicles. Prioritizing emergency sce- narios enables the project to target and demonstrate mea- surable enhancements in response times, providing empirical evidence of efficacy. The successful deployment and validation of this system are intended to lay a robust foundation for the subsequent expansion of these technologies to general traffic management applications.

3) Resource Allocation: While the current phase of the

project is predominantly centered on software development and does not necessitate a broad allocation of physical re- sources, substantial computational resources are indispensable. The development, training, and deployment of Convolutional Neural Networks (CNN’s) to process and analyze complex traffic datasets demand an advanced computing infrastruc- ture. Consequently, the project will leverage either cloud- based computing services or on-premises servers equipped with high-performance GPUs and CPUs. These resources are essential to support the computationally intensive demands of developing machine learning models and managing real-time traffic data processing.

This meticulously crafted planning framework is designed to align all project activities with the overarching strategic ob- jectives of significantly enhancing emergency response capa- bilities through cutting-edge traffic management technologies. By initially concentrating on emergency vehicle scenarios, the project establishes a focused and impactful benchmark for broader traffic system enhancements, setting a precedent for future scalability and adaptability in traffic management solutions.

3. SYSTEM REQUIREMENTS AND DATA SPECIFICATIONS
1. Hardware Requirements

The hardware specific requirements for our project are as given below.

1) Sensors : We would require some IoT related sensors

for the project like a high-resolution camera for reading and detecting the vehicles from the road, and also some sensors will be required for V2V and V2I communications.

2) Computing Devices : We will require micro-computers

to be implemented at the end devices/sensors for performing the decision tasks. These will be generally SoC or NoC IoT Devices used for V2V/V2I Communications.

3) Processors : We will require some high levels of

compute-intensive CPUs and GPUs for training model with a large dataset.

2. Software Requirements

The software specific requirements for our project are as given below.

1) Programming Language: We have used Java and Python

as the base programming language in project.

2) Libraries Used: OpenCV, Numpy, JavaFX.
2) Models Used: YOLOv8, EasyOCR.
2) Algorithms Used: A\*, Dijkstra, and BFS algorithm to

frame the shortest path between two given end points.

3. Datasets

We have compiled an extensive collection of datasets from publicly available sources, with the ’Emergency Vehicle De- tection Computer Vision Project Dataset’ [6] being particularly significant. Additionally, we have augmented these resources with a custom dataset specifically curated for the enhancement of emergency vehicle detection capabilities.

4. SYSTEM DESIGN / WORKING IMPLEMENTATION

This section elaborates on the sophisticated implementation of a dynamic traffic flow management system, meticulously designed to optimize urban traffic by integrating advanced computational models with data-driven verification processes. This system encompasses a four-tiered framework, as visually demonstrated in Fig 2 that includes YOLOv8 for emergency vehicle detection, Easy-OCR for license plate recognition, the National Informatics Centre (NIC) database for vehicle verification, and advanced path-finding algorithms to facilitate efficient route optimization.

1. Emergency Vehicle Detection Using YOLOv8

The initial phase of our deployment involves the YOLOv8 model, which is leveraged for real-time detection of emergency vehicles. As the latest evolution in the YOLO series, YOLOv8 is celebrated for its rapid and precise object detection capabil- ities, making it exceedingly suitable for real-time applications within traffic management systems. This model operates on a rigorously curated custom dataset sourced from a variety of open-source repositories, ensuring a comprehensive and representative training foundation. The primary objective here is to identify emergency vehicles instantaneously from live video feeds at urban intersections, marking the first step in a dual-stage verification process aimed at enhancing the prioritization of emergency responses within urban traffic management strategies [7], [9].

![](Aspose.Words.c202e6b7-bb2d-4c8f-bbe5-d51365998a2b.002.png)

Fig. 2: System Design Interpretation

2. Easy-OCR for License Plate Recognition

Subsequent to vehicle detection, the Easy-OCR tool is utilized to perform real-time text extraction from vehicle license plates. Easy-OCR’s versatility in supporting multiple languages and scripts makes it an ideal choice for accurately recognizing license plates under diverse operational condi- tions. This functionality forms the second segment of the verification process, where OCR results are further analyzed to validate vehicle identities and check their registration statuses against set criteria [8].

![](Aspose.Words.c202e6b7-bb2d-4c8f-bbe5-d51365998a2b.003.png)

Fig. 3: Easy-OCR Implementation

3. NIC Database Integration

We have are using it for Two-Step Verification process for more safety and confirming the vehicles. Integrating the NIC database is a pivotal step for the real-time verification of vehicles detected through YOLOv8 and Easy-OCR. The NIC database acts as a comprehensive repository of vehicle registration data, facilitating the verification of whether a detected vehicle meets the emergency criteria based on its registration details. This integration is essential for enabling

TABLE I: YOLO Model Benchmarks



|Models|mAP (COCO)|AP@0.5 (COCO)|Speed on AGX Orin (FPS)|Speed on RTX 4070 Ti (FPS)|
| - | - | - | - | - |
|YOLOv5s|37\.4|56\.8|277|877|
|YOLOv5m|45\.4|64\.1|160|586|
|YOLOv5l|49\.0|67\.3|116|446|
|YOLOv5x|50\.7|68\.9|67|252|
|YOLOv7-tiny|37\.4|55\.2|290|917|
|YOLOv7|51\.2|69\.7|115|452|
|YOLOv7x|52\.9|71\.1|77|294|
|YOLOv8n|37\.3|52\.5|383|1163|
|YOLOv8s|44\.9|61\.8|260|925|
|YOLOv8m|50\.2|67\.2|137|540|
|YOLOv8l|52\.9|69\.8|95|391|
|YOLOv8x|53\.9|71\.0|64|236|



![](Aspose.Words.c202e6b7-bb2d-4c8f-bbe5-d51365998a2b.004.png)

Fig. 4: Emergency Vehicle Detection

prioritized traffic management for emergency vehicles, thereby enhancing their ability to traverse urban environments more efficiently during critical situations [11].

4. Path-finding Algorithm

We have used Breadth First Search (BFS), Dijkstra’s and A\* algorithm here in our project work. The deployment of sophisticated path-finding algorithms constitutes the final aspect of our system’s implementation. The A\* algorithm is employed for its heuristically-enhanced efficiency in discover- ing the shortest paths, whereas Dijkstra’s algorithm is utilized for its straightforwardness and effectiveness in navigating weighted networks [5]. Additionally, the Breadth-First Search (BFS) algorithm is applied due to its proficiency in exploring unweighted graphs, offering substantial benefits in specific traffic scenarios. Collectively, these algorithms underpin the system’s dynamic traffic rerouting capabilities, significantly ameliorating urban traffic congestion [4], [12].

5. RESULTS ANALYSIS
1. YOLOv8 for Emergency Vehicles Detection

This analysis section elucidates the rationale for selecting the YOLOv8 model for real-time detection of emergency vehicles at urban intersections within our comprehensive traffic management system. The decision is substantiated by a rigor- ous comparative evaluation of the model’s performance against its predecessors, YOLOv5 and YOLOv7, across two hardware

configurations—NVIDIA Jetson AGX Orin and RTX 4070 Ti. The evaluation criteria focused on Mean Average Precision (mAP) across varied Intersection over Union (IoU) thresholds and the models’ operational speeds, quantified in frames per second (FPS).

1) Comparative Performance Evaluation: To identify the

most suitable YOLO model for our application, a detailed anal- ysis was conducted. The models assessed included YOLOv5, YOLOv7, and YOLOv8. The primary metrics for evaluation were mAP and operational speed across different IoU thresh- olds. Performance data compiled from a Stereolabs study [10] in Table I, highlights the advancements incorporated in YOLOv8.

2) Performance metrics defined:
   1. Mean Average Precision (mAP): This metric evaluates the model’s precision across multiple thresholds, providing an average score that reflects its overall ability to identify correct objects within the images accurately.
   1. Average Precision at IoU=0.5 (AP@0.5): This specific metric calculates the precision at an IoU threshold of 0.5, offering insight into the model’s performance at this moderate level of detection strictness.
   1. Intersection over Union (IoU): IoU quantifies the ac- curacy of an object detector on a particular dataset, measured by the overlap between the predicted bounding boxes and the ground truth.
2) Justification for the Selection of YOLOv8:The deploy-

ment of YOLOv8 was driven by its superior performance indicators compared to its predecessors. Notably, the high-end configurations of YOLOv8, such as YOLOv8l and YOLOv8x, not only delivered the highest mAP scores but also maintained processing speeds viable for real-time applications:

- Accuracy and Speed Trade-off: The YOLOv8 variants strike an optimal balance between high detection accuracy and efficient processing speed, ensuring robust perfor- mance in real-time operational settings.
- Real-Time Processing Capability: The YOLOv8 model variants, particularly those with lower resolutions like YOLOv8n, achieve processing speeds up to 383 FPS, thereby facilitating the swift detection of emergency

vehicles essential for prompt traffic management inter- ventions.

Integrating YOLOv8 into our traffic management system significantly augments the detection capabilities and opera- tional efficiency, ensuring rapid and accurate identification of emergency vehicles. This enhancement is pivotal for improv- ing response times and optimizing traffic flow across urban settings.

2. Analysis of Path-finding Algorithms: Comparative Analysis with Google Maps and Apple Maps

   In this segment of our analysis, we embarked on an empir- ical analysis to evaluate the efficiency of various path-finding algorithms implemented within our proprietary project, specif- ically comparing them against established route suggestion systems such as Google Maps, Apple Maps and Bing Maps. The starting point for our analysis was the KP 5 hostel at KIIT Bhubaneswar, with the destination set as TCS Bhubaneswar. This setting allowed us to assess the practical applicability of our algorithms under controlled conditions.

1) Methodology: As demonstrated in Fig 5, we utilized

screenshots from Google Maps, Apple Maps, Bing Maps, and our own project’s outputs to visualize and compare the suggested routes. Our project incorporates three distinct algorithms: Breadth-First Search (BFS), Dijkstra’s, and A\*. Each algorithm’s route output was documented and analyzed against the routes provided by Google Maps and Apple Maps, which consider various dynamic factors such as current traffic conditions and road closures.

2) Rationale for Independent Navigation System Develop-

ment: The development of our own navigation system was driven by the need for enhanced security, independence, and seamless integration with other project services. By designing a bespoke navigation solution, we aimed to create a secure and controlled environment that mitigates risks associated with third-party data dependencies and integrates tightly with our broader traffic management infrastructure.

3) Results: The experimental results indicate that our im-

plementations of Dijkstra’s and A\* algorithms frequently provided shorter or more efficient paths compared to those suggested by Google Maps and Apple Maps. Notably:

- Dijkstra’s Algorithm: showed considerable promise in de- livering cost-effective paths, underscoring its robustness in handling weighted graphs which represent real-world road networks with varied distances.
- A\* Algorithm: demonstrated superior performance in terms of computational efficiency, leveraging heuristics to expedite pathfinding under constrained scenarios. This algorithm effectively reduced the route discovery time, making it a viable option for real-time applications.

However, it is critical to acknowledge that the routes suggested by commercial mapping services are influenced by a comprehensive array of live data inputs including traffic patterns, road conditions, and infrastructural modifications, factors that our current project setup does not fully integrate.

This comparative analysis highlights the potential of integrating advanced pathfinding algorithms within traffic management systems. The findings suggest that while Dijkstra’s and A\* can provide faster routing solutions, the integration of real-time data, akin to that used by Google Maps and Apple Maps, could further enhance their applicability and accuracy in practical scenarios.

The inherent limitations of BFS in handling weighted paths were evident, suggesting its unsuitability for complex urban traffic systems where variable road weights (distances, traffic densities) significantly affect routing decisions.

6. STANDARDS ADOPTED

The adoption of rigorous coding standards is essential for maintaining the integrity and efficacy of software development within research environments. This section outlines the key coding standards implemented in this project to ensure high quality, maintainability, and ease of future enhancements.

1. Conciseness

The principle of conciseness is central to our coding prac- tice. It emphasizes the elimination of unnecessary verbosity and repetition, thereby enhancing the clarity and brevity of the code. Concise coding practices not only streamline the development process but also ensure that the software remains accessible to collaborators and future contributors, facilitating ongoing project sustainability.

2. Naming Conventions

Utilizing meaningful and consistent naming conventions is crucial for ensuring the clarity of the codebase. This standard involves using descriptive and intuitive names for variables, functions, and classes to clearly reflect their roles and func- tionalities. Such practices promote ease of understanding and uniformity, significantly reducing the cognitive load required to navigate and comprehend the code.

3. Code Structure

Effective code structuring involves organizing code into logical segments and modules, which enhances readability and maintainability. Adhering to consistent practices in indentation and spacing further improves the legibility of the code, while logically grouping related functionalities fosters better coher- ence and modular integrity. These structural considerations are pivotal in supporting efficient code navigation and modifica- tion.

4. Modularity

Modularity refers to the practice of encapsulating function- ality into distinct, reusable components, thereby promoting code reuse and system extensibility. This approach simplifies the breakdown of complex tasks into smaller, manageable units, which can be independently developed and tested. Clear interfaces defining the inputs, outputs, and behaviors of modules enhance their interoperability and facilitate future scalability.

![](Aspose.Words.c202e6b7-bb2d-4c8f-bbe5-d51365998a2b.005.png) ![](Aspose.Words.c202e6b7-bb2d-4c8f-bbe5-d51365998a2b.006.png)

Path finding navigation in Google Maps Path finding navigation in Apple Maps

![](Aspose.Words.c202e6b7-bb2d-4c8f-bbe5-d51365998a2b.007.png) ![](Aspose.Words.c202e6b7-bb2d-4c8f-bbe5-d51365998a2b.008.png)

Path finding navigation in Bing Maps Path finding navigation in Project’s BFS algorithm

![](Aspose.Words.c202e6b7-bb2d-4c8f-bbe5-d51365998a2b.009.png) ![](Aspose.Words.c202e6b7-bb2d-4c8f-bbe5-d51365998a2b.010.png)

Path finding navigation in Project’s Dijkstra algorithm Path finding navigation in Project’s A\* algorithm

Fig. 5: Comparative mapping and algorithm visualization across different platforms and methods

5. Documentation

Comprehensive documentation, including inline comments and extensive docstrings, is indispensable for elucidating the underlying logic and usage of the code. Documentation that clearly describes function parameters, expected outputs, and potential side effects is invaluable for guiding both users and future developers. Additionally, detailed explanations of complex algorithms or non-trivial code implementations are crucial for fostering deeper understanding and collaboration.

6. Error Handling

Robust error handling mechanisms enhance the stability and reliability of software. This involves anticipating potential errors and implementing strategies to handle exceptions grace- fully, thereby preventing program crashes and ensuring con- tinuous operation. Strategies such as using try-except blocks and conducting conditional checks are employed to manage unexpected situations effectively.

7. Testing

Comprehensive automated testing frameworks are employed to ascertain the correctness and reliability of the software. This involves creating tests that cover both common use cases and edge conditions, ensuring comprehensive validation of the system’s functionality. Utilizing well-established testing methodologies, such as unit testing and integration testing, reinforces the software’s robustness and fidelity.

8. Performance Optimization

Performance optimization involves refining critical sections of the code to enhance efficiency while balancing consid- erations for maintainability and clarity. Techniques such as algorithmic enhancement and thoughtful refactoring are used to mitigate performance bottlenecks. This balanced approach ensures that performance improvements do not obscure the code’s functionality or degrade its readability.

Adherence to these established coding standards is paramount for ensuring the development of high-quality, ro- bust, and maintainable software within academic research environments. By consistently applying these principles, the project not only aligns with best practices but also significantly contributes to the broader scientific community by enhancing the reproducibility and usability of its outputs.

CONCLUSION

The research presented in this paper underscores the signif- icant advances in the field of automatic number plate recog- nition (ANPR) by showcasing the effectiveness of machine learning algorithms in enhancing car number plate detec- tion and recognition. Our experimental results demonstrate that the custom-developed algorithms—especially Dijkstra’s and A\*—not only match but occasionally surpass the route optimization solutions offered by existing technologies such as Google Maps and Apple Maps in static environments. This achievement highlights the potential of integrating these

advanced computational techniques into broader traffic man- agement systems, offering a more secure and independent nav- igation solution that respects privacy while optimizing urban traffic flow. Future work will focus on refining these algorithms to incorporate real-time traffic data, aiming to produce a truly dynamic navigation system that responds to real-world con- ditions, thereby making a substantial contribution to the field of intelligent transportation systems. This study lays a robust foundation for further innovation and application of machine learning in traffic management and vehicle monitoring.

7. FUTURE SCOPE
1. Integration of Advanced AI Technologies:

Research indicates that AI-based smart traffic management systems are not only becoming more sophisticated but are also integrating emerging AI technologies like reinforcement learning and neural networks to optimize traffic flows dynam- ically (Source:”AI Based Smart Traffic Management”). These systems could predict traffic volumes and adjust signals in real time, significantly reducing congestion and improving road safety.

2. Autonomous Vehicle Coordination:

The advent of autonomous vehicles presents a new frontier for traffic management systems. Future developments are expected to focus on the integration of vehicle-to-infrastructure (V2I) and vehicle-to-vehicle (V2V) communications, allowing for seamless coordination between autonomous vehicles and traffic control mechanisms (Source: ”Smart Traffic Manage- ment using Deep Learning”). This coordination could facili- tate smoother traffic flow and enhanced situational awareness among autonomous agents.

3. Scalable Infrastructure Adaptations:

As cities continue to grow, scalable solutions that can adapt to increasing traffic demands are crucial. Future traf- fic management systems will likely incorporate modular AI components that can be upgraded as computational capabil- ities improve and traffic patterns evolve (Source: ”Designing Traffic Management Strategies Using Reinforcement Learning Techniques”). This adaptability will be critical in maintaining the efficiency and effectiveness of traffic systems in large urban centers.

4. Enhanced Data Analytics for Predictive Modeling:

Deep learning techniques, particularly those involving large- scale data analytics, are poised to improve the predictive ca- pabilities of traffic management systems (Source: ”Automated Traffic Management System Using Deep Learning Based Object Detection”). By analyzing vast datasets collected from sensors and cameras, these systems can forecast long-term traffic trends and prepare for future demands effectively.
