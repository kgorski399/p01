import json
import boto3
import decimal

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
ssm = boto3.client('ssm')
table = dynamodb.Table('Farm')

def get_farm_id():
    response = ssm.get_parameter(Name='farm_id')
    return response['Parameter']['Value']

def lambda_handler(event, context):
    farm_id = get_farm_id()

    try:
        response = table.get_item(Key={'farm_id': farm_id})

        item = response['Item']
        satisfaction = int(item.get('satisfaction', 0))  

        return {
            "statusCode": 200,
            "farm_id": farm_id,
            "satisfaction": satisfaction 
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "error": str(e)
        }
