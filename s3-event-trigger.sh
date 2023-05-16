#!/bin/bash

# Execution Trace Mode
set -x

# Get AWS account ID
aws_account_id=$(aws sts get-caller-identity --query 'Account' --output text)

# Print AWS account id
echo "AWS Account Id: $aws_account_id"

# Config Setup
aws_region="us-east-1"
bucket_name="event-trigger-prason-project"
lambda_func_name="s3-lambda-function"
role_name="s3-lambda-sns"
email_address="mailme.prashant07@gmail.com"

# Create IAM role
role_response=$(aws iam create-role --role-name s3-lambda-sns --assume-role-policy-document '{
  "Version": "2012-10-17",
  "Statement": [{
    "Action": "sts:AssumeRole",
    "Effect": "Allow",
    "Principal": {
      "Service": [
         "lambda.amazonaws.com",
         "s3.amazonaws.com",
         "sns.amazonaws.com"
      ]
    }
  }]
}')

# Extract role ARN 
role_arn=$(echo "$role_response" | jq -r '.Role.Arn')

# Print role ARN 
echo "Role ARN: $role_arn"

# Attach Permissions to the Role 
aws iam attach-role-policy --role-name $role_name --policy-arn arn:aws:iam::aws:policy/AWSLambda_FullAccess
aws iam attach-role-policy --role-name $role_name --policy-arn arn:aws:iam::aws:policy/AmazonSNSFullAccess
aws iam attach-role-policy --role-name $role_name --policy-arn arn:aws:iam::aws:policy/CloudWatchFullAccess


# Create bucket 
bucket_response=$(aws s3api create-bucket --bucket "$bucket_name" --region "$aws_region")

# Print Bucket response  
echo "Bucket Creation Output: $bucket_response"

# Upload a test file
aws s3 cp ./test.txt s3://"$bucket_name"/test.txt 

# Create a Zip file to upload Lambda Function 
zip -r s3-lambda-func.zip ./lambda/

sleep 5

# Create a Lambda Function 
aws lambda create-function \
  --region "$aws_region" \
  --function-name "$lambda_func_name" \
  --runtime "python3.8" \
  --handler "lambda/lambda_function.lambda_handler" \
  --memory-size 128 \
  --timeout 30 \
  --role "arn:aws:iam::$aws_account_id:role/$role_name" \
  --zip-file "fileb://./s3-lambda-func.zip"

# Add Lambda permission to allow invoking by s3 event 
aws lambda add-permission \
  --region "$aws_region" \
  --function-name "$lambda_func_name" \
  --statement-id "s3-lambda-sns-statement" \
  --action "lambda:InvokeFunction" \
  --principal s3.amazonaws.com \
  --source-arn "arn:aws:s3:::$bucket_name"

# Create s3 event trigger for Lambda Function 
LambdaFunctionArn="arn:aws:lambda:us-east-1:$aws_account_id:function:s3-lambda-function"
aws s3api put-bucket-notification-configuration \
  --region "$aws_region" \
  --bucket "$bucket_name" \
  --notification-configuration '{
    "LambdaFunctionConfigurations": [{
        "LambdaFunctionArn": "'"$LambdaFunctionArn"'",
        "Events": ["s3:ObjectCreated:*"]
    }]
}'

# Create SNS topic
topic_arn=$(aws sns create-topic --name s3-lambda-sns-topic --output json | jq -r '.TopicArn')

# Print Topic Arn 
echo "SNS Topic ARN: $topic_arn"

# Add SNS publish permission 
aws sns subscribe \
  --region "$aws_region" \
  --topic-arn "$topic_arn" \
  --protocol email \
  --notification-endpoint "$email_address"

