import json
import os
import boto3
import time

dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

def lambda_handler(event, context):
    for record in event['Records']:
        message = json.loads(record['body'])
        order_id = message['order_id']
        customer_id = message['customer_id']
        total = message['total']
        
        # simulating heavy processing
        print(f"Checking inventory for {order_id}...")
        time.sleep(0.5)
        
        print(f"Running fraud detection for {order_id}...")
        time.sleep(0.8)
        
        print(f"Processing payment for {order_id}...")
        time.sleep(1.2)
        
        table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])
        table.update_item(
            Key={'order_id': order_id},
            UpdateExpression='SET #status = :status',
            ExpressionAttributeNames={'#status': 'status'},
            ExpressionAttributeValues={':status': 'COMPLETED'}
        )
        
        sns.publish(
            TopicArn=os.environ['SNS_TOPIC_ARN'],
            Subject=f'Order Completed - {order_id}',
            Message=f'Order {order_id} for ${total} has been processed successfully!'
        )
        
        print(f"Order {order_id} completed!")