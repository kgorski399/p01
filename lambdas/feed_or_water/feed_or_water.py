import json
import boto3
from datetime import datetime

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
ssm = boto3.client('ssm')
table = dynamodb.Table('Farm')

def get_farm_id():
    response = ssm.get_parameter(Name='farm_id')
    return response['Parameter']['Value']

def lambda_handler(event, context):
    farm_id = get_farm_id()

    action = event.get('queryStringParameters', {}).get('action') 

    if action == 'water':
        update_field = 'waterDate'
    elif action == 'feed':
        update_field = 'feedDate'
    else:
        return {
            "statusCode": 400,
            "headers": {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
            },
            "body": json.dumps("Invalid action. Please specify 'water' or 'feed'.")
        }

    response = table.update_item(
        Key={'farm_id': farm_id},
        UpdateExpression=f"SET {update_field} = :date",
        ExpressionAttributeValues={':date': datetime.now().isoformat()},
        ReturnValues="UPDATED_NEW"
    )
    
    return {
        "statusCode": 200,
        "headers": {
            'Access-Control-Allow-Origin': '*',
            'Content-Type': 'application/json'
        },
        "body": json.dumps(f"Successfully updated {update_field}")
    }
