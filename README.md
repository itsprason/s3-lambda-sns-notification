# S3 Lambda Function with SNS Notification

This project demonstrates an AWS Lambda function that gets triggered when an object is uploaded to an S3 bucket. The Lambda function sends a notification using Amazon SNS to notify about the uploaded file.

## Prerequisites

- AWS CLI configured with appropriate access credentials.
- Python 3.8 or higher installed locally.
- Git installed on your machine.

## Setup Instructions

1. Clone the repository:

```bash
   git clone https://github.com/itsprason/s3-lambda-sns-notification.git
```
2. Navigate to the project directory:
    
```bash
cd s3-lambda-function
```

Execute the shell script to set up the AWS resources and deploy the Lambda function:

``` bash
./s3-event-trigger.sh
```

This script creates an IAM role, S3 bucket, Lambda function, SNS topic, and configures the necessary permissions and event triggers.

After the script finishes executing, you will receive an email confirmation for subscribing to the SNS topic. Confirm the subscription to start receiving notifications.

## Usage

Upload a file to the S3 bucket created during the setup. The Lambda function will be triggered automatically, and you will receive an email notification indicating the uploaded file details.


## Cleanup

To clean up the AWS resources created by this project, follow these steps:

Delete the S3 bucket:

``` bash
aws s3 rb s3://event-trigger-prason-project --force
```

Delete the Lambda function:

``` bash
aws lambda delete-function --function-name s3-lambda-function
```

Delete the IAM role:

```bash
aws iam delete-role --role-name s3-lambda-sns
```
