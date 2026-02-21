import json
import pytest
from unittest.mock import Mock, patch
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../../src/lambda/accept-order'))

import index

@pytest.fixture
def api_gateway_event():
    """Mock API Gateway event"""
    return {
        'body': json.dumps({
            'order_id': 'TEST_001',
            'customer_id': 'CUST_123',
            'total': 99.99
        }),
        'headers': {'Content-Type': 'application/json'}
    }

@pytest.fixture
def lambda_context():
    """Mock Lambda context"""
    context = Mock()
    context.request_id = 'test-request-id'
    return context

@patch.dict(os.environ, {
    'DYNAMODB_TABLE': 'test-orders',
    'SQS_QUEUE_URL': 'https://sqs.us-east-1.amazonaws.com/123/test-queue'
})
@patch('index.dynamodb')
@patch('index.sqs')
def test_accept_order_success(mock_sqs, mock_dynamodb, api_gateway_event, lambda_context):
    """Test successful order acceptance"""
    
    mock_table = Mock()
    mock_dynamodb.Table.return_value = mock_table
    
    response = index.lambda_handler(api_gateway_event, lambda_context)
    
    assert response['statusCode'] == 202
    body = json.loads(response['body'])
    assert body['order_id'] == 'TEST_001'
    assert 'accepted' in body['message'].lower()
    
    mock_table.put_item.assert_called_once()
    call_args = mock_table.put_item.call_args[1]['Item']
    assert call_args['order_id'] == 'TEST_001'
    assert call_args['status'] == 'PENDING'
    
    mock_sqs.send_message.assert_called_once()

@patch.dict(os.environ, {
    'DYNAMODB_TABLE': 'test-orders',
    'SQS_QUEUE_URL': 'https://sqs.us-east-1.amazonaws.com/123/test-queue'
})
def test_accept_order_missing_fields(lambda_context):
    """Test order rejection when fields are missing"""
    
    event = {
        'body': json.dumps({
            'order_id': 'TEST_001'
        })
    }
    
    with pytest.raises(KeyError):
        index.lambda_handler(event, lambda_context)