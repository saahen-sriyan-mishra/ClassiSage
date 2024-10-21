import json
import subprocess
import os

# Retrieve bucket name from TF output
def get_bucket_name():
    try:
        print("Attempting to get Terraform output...")
        # Specify the working directory for .tf files location
        output = subprocess.check_output('terraform output -json', shell=True, cwd = r'<PATH_TO_THE_CLONED_FILE>') #C:\Users\Saahen\Desktop\ClassiSage
        
        # Decode the output
        print("Raw Terraform Output:", output.decode('utf-8'))  # Decode bytes to string
        outputs = json.loads(output) #check
        
        # Debug: Print the parsed o/p
        print("Parsed Outputs:", json.dumps(outputs, indent=4))
        
        # Access the bucket
        return outputs['bucket_name']['value']
    
    except subprocess.CalledProcessError as e:
        print(f"Subprocess Error: {e}. Command output: {e.output.decode('utf-8')}")
    except KeyError as e:
        print(f"KeyError: {e}. Please check the output keys.")
    except json.JSONDecodeError as e:
        print(f"JSON Decode Error: {e}. Output was: {output.decode('utf-8')}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

def check_file_creation(local_file_path):
    # Debug: Check for successful creation
    if os.path.exists(local_file_path):
        print(f"Local file {local_file_path} created successfully.")
    else:
        print(f"Failed to create local file {local_file_path}.")

