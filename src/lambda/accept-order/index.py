import json
import os
import boto3
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
sqs = boto3.client('sqs')

def lambda_handler(event, context):
    body = json.loads(event['body'])
    order_id = body['order_id']
    customer_id = body['customer_id']
    total = body['total']
    
    table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])
    table.put_item(Item={
        'order_id': order_id,
        'customer_id': customer_id,
        'total': str(total),
        'status': 'PENDING',
        'timestamp': datetime.utcnow().isoformat()
    })
    
    sqs.send_message(
        QueueUrl=os.environ['SQS_QUEUE_URL'],
        MessageBody=json.dumps({
            'order_id': order_id,
            'customer_id': customer_id,
            'total': total
        })
    )
    
    return {  
        'statusCode': 202,
        'body': json.dumps({
            'message': 'Order accepted for processing',
            'order_id': order_id
        })
    }