import json
import pytest
from unittest.mock import Mock
import os
import sys
from moto import mock_aws

@pytest.fixture
def lambda_context():
    context = Mock()
    context.request_id = 'test-request-id'
    return context

@mock_aws
def test_get_single_order_found(lambda_context):
    """Test retrieving a single order that exists"""
    
    os.environ['DYNAMODB_TABLE'] = 'test-orders'
    os.environ['AWS_DEFAULT_REGION'] = 'us-east-1'
    
    sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../../src/lambda/get-orders'))
    import index
    
    import boto3
  
    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
    table = dynamodb.create_table(
        TableName='test-orders',
        KeySchema=[{'AttributeName': 'order_id', 'KeyType': 'HASH'}],
        AttributeDefinitions=[{'AttributeName': 'order_id', 'AttributeType': 'S'}],
        BillingMode='PAY_PER_REQUEST'
    )
    
    table.put_item(Item={
        'order_id': 'TEST_001',
        'customer_id': 'CUST_123',
        'total': '99.99',
        'status': 'COMPLETED'
    })

    event = {
        'routeKey': 'GET /orders/{order_id}',
        'pathParameters': {'order_id': 'TEST_001'}
    }
 
    response = index.lambda_handler(event, lambda_context)

    assert response['statusCode'] == 200
    body = json.loads(response['body'])
    assert body['order_id'] == 'TEST_001'

@mock_aws
def test_get_single_order_not_found(lambda_context):
    """Test retrieving an order that doesn't exist"""
    
    os.environ['DYNAMODB_TABLE'] = 'test-orders'
    os.environ['AWS_DEFAULT_REGION'] = 'us-east-1'
    
    sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../../src/lambda/get-orders'))
    import index
    
    import boto3

    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
    dynamodb.create_table(
        TableName='test-orders',
        KeySchema=[{'AttributeName': 'order_id', 'KeyType': 'HASH'}],
        AttributeDefinitions=[{'AttributeName': 'order_id', 'AttributeType': 'S'}],
        BillingMode='PAY_PER_REQUEST'
    )
    
    event = {
        'routeKey': 'GET /orders/{order_id}',
        'pathParameters': {'order_id': 'NONEXISTENT'}
    }
    
    response = index.lambda_handler(event, lambda_context)
    
    assert response['statusCode'] == 404