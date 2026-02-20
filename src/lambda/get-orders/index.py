import json
import os
import boto3
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')

def decimal_to_number(obj):
    if isinstance(obj, Decimal):
        return float(obj) if obj % 1 else int(obj)
    return obj

def lambda_handler(event, context):
    table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])
    
    route_key = event.get('routeKey')
    
    if route_key == 'GET /orders/{order_id}':
        order_id = event['pathParameters']['order_id']
        
        response = table.get_item(Key={'order_id': order_id})
        
        if 'Item' not in response:
            return {
                'statusCode': 404,
                'body': json.dumps({'error': 'Order not found'})
            }
        
        return {
            'statusCode': 200,
            'body': json.dumps(response['Item'], default=decimal_to_number)
        }
    
    elif route_key == 'GET /orders':
        query_params = event.get('queryStringParameters') or {}
        status_filter = query_params.get('status')
        
        if status_filter:
            response = table.scan(
                FilterExpression='#status = :status',
                ExpressionAttributeNames={'#status': 'status'},
                ExpressionAttributeValues={':status': status_filter}
            )
        else:
            response = table.scan()
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'orders': response['Items'],
                'count': len(response['Items'])
            }, default=decimal_to_number)
        }
    
    return {
        'statusCode': 400,
        'body': json.dumps({'error': 'Invalid route'})
    }