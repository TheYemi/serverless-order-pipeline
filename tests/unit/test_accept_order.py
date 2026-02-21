import json
import pytest
from unittest.mock import Mock, patch, MagicMock
import os
import sys
from moto import mock_aws

@pytest.fixture
def lambda_context():
    """Mock Lambda context"""
    context = Mock()
    context.request_id = 'test-request-id'
    context.function_name = 'test-function'
    context.memory_limit_in_mb = 128
    return context

@mock_aws
def test_accept_order_success(lambda_context):
    """Test successful order acceptance"""

    os.environ['DYNAMODB_TABLE'] = 'test-orders'
    os.environ['SQS_QUEUE_URL'] = 'https://sqs.us-east-1.amazonaws.com/123/test-queue'
    os.environ['AWS_DEFAULT_REGION'] = 'us-east-1'

    sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../../src/lambda/accept-order'))
    import index
    
    import boto3
    
    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
    table = dynamodb.create_table(
        TableName='test-orders',
        KeySchema=[{'AttributeName': 'order_id', 'KeyType': 'HASH'}],
        AttributeDefinitions=[{'AttributeName': 'order_id', 'AttributeType': 'S'}],
        BillingMode='PAY_PER_REQUEST'
    )
    
    sqs = boto3.client('sqs', region_name='us-east-1')
    queue = sqs.create_queue(QueueName='test-queue')
    
    event = {
        'body': json.dumps({
            'order_id': 'TEST_001',
            'customer_id': 'CUST_123',
            'total': 99.99
        }),
        'headers': {'Content-Type': 'application/json'}
    }
    
    response = index.lambda_handler(event, lambda_context)
    
    assert response['statusCode'] == 202
    body = json.loads(response['body'])
    assert body['order_id'] == 'TEST_001'
    assert 'accepted' in body['message'].lower()
    
    result = table.get_item(Key={'order_id': 'TEST_001'})
    assert 'Item' in result
    assert result['Item']['status'] == 'PENDING'