/* 


import mysql.connector
import boto3

# Initialize S3 client
s3_client = boto3.client('s3')

# Fetch the SQL file from S3
bucket_name = 'your-s3-bucket'
sql_file_key = 'path/to/your/sql_queries.sql'

# Download the SQL file
response = s3_client.get_object(Bucket=bucket_name, Key=sql_file_key)
sql_script = response['Body'].read().decode('utf-8')

# Connect to the RDS instance
conn = mysql.connector.connect(
    host='your-rds-endpoint',
    user='your-db-username',
    password='your-db-password',
    database='your-database-name'
)

cursor = conn.cursor()

# Split SQL file into individual queries
queries = sql_script.split(';')

# Execute each query
for query in queries:
    if query.strip():
        cursor.execute(query)

# Commit the changes if needed
conn.commit()

# Close the connection
cursor.close()
conn.close()



*/