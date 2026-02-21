import json
import pytest
from unittest.mock import Mock, patch
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../../src/lambda/get-orders'))

import index

@pytest.fixture
def lambda_context():
    context = Mock()
    context.request_id = 'test-request-id'
    return context

@patch.dict(os.environ, {'DYNAMODB_TABLE': 'test-orders'})
@patch('index.dynamodb')
def test_get_single_order_found(mock_dynamodb, lambda_context):
    """Test retrieving a single order that exists"""
    
    mock_table = Mock()
    mock_table.get_item.return_value = {
        'Item': {
            'order_id': 'TEST_001',
            'customer_id': 'CUST_123',
            'total': '99.99',
            'status': 'COMPLETED'
        }
    }
    mock_dynamodb.Table.return_value = mock_table
    
    event = {
        'routeKey': 'GET /orders/{order_id}',
        'pathParameters': {'order_id': 'TEST_001'}
    }

    response = index.lambda_handler(event, lambda_context)
    
    assert response['statusCode'] == 200
    body = json.loads(response['body'])
    assert body['order_id'] == 'TEST_001'

@patch.dict(os.environ, {'DYNAMODB_TABLE': 'test-orders'})
@patch('index.dynamodb')
def test_get_single_order_not_found(mock_dynamodb, lambda_context):
    """Test retrieving an order that doesn't exist"""
    
    mock_table = Mock()
    mock_table.get_item.return_value = {}
    mock_dynamodb.Table.return_value = mock_table
    
    event = {
        'routeKey': 'GET /orders/{order_id}',
        'pathParameters': {'order_id': 'NONEXISTENT'}
    }
    
    response = index.lambda_handler(event, lambda_context)
    
    assert response['statusCode'] == 404

@patch.dict(os.environ, {'DYNAMODB_TABLE': 'test-orders'})
@patch('index.dynamodb')
def test_list_all_orders(mock_dynamodb, lambda_context):
    """Test listing all orders"""
    
    mock_table = Mock()
    mock_table.scan.return_value = {
        'Items': [
            {'order_id': 'TEST_001', 'status': 'COMPLETED'},
            {'order_id': 'TEST_002', 'status': 'PENDING'}
        ]
    }
    mock_dynamodb.Table.return_value = mock_table
    
    event = {
        'routeKey': 'GET /orders',
        'queryStringParameters': None
    }
    
    response = index.lambda_handler(event, lambda_context)
    
    assert response['statusCode'] == 200
    body = json.loads(response['body'])
    assert body['count'] == 2
    assert len(body['orders']) == 2