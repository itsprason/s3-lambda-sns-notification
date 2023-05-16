import boto3 
import json 

def lambda_handler(event, context):
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    object_key = event['Records'][0]['s3']['object']['key']

    print(f"File '{object_key}' was uploaded to bucket '{bucket_name}'")

    # Send Notification
    sns_client = boto3.client('sns')
    topic_arn = 'arn:aws:sns:us-east-1:<Account-ID>:s3-lambda-sns-topic'
    sns_client.publish(
       TopicArn=topic_arn,
       Subject='S3 Object Created',
       Message=f"File '{object_key}' was uploaded to bucket '{bucket_name}'"
    )


    return {
        'statusCode': 200,
        'body': json.dumps('Lambda function executed successfully')
    }
