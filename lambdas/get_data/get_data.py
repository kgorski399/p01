import json
import boto3

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

        if 'Item' not in response:
            return {
                "statusCode": 404,
                "headers": {
                    'Access-Control-Allow-Origin': '*',
                    'Content-Type': 'application/json'
                },
                "body": json.dumps("Farm not found")
            }

        item = response['Item']
        water_date = item.get('waterDate', 'Not available')
        feed_date = item.get('feedDate', 'Not available')

        return {
            "statusCode": 200,
            "headers": {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
            },
            "body": json.dumps({
                "farm_id": farm_id,
                "last_watered": water_date,
                "last_fed": feed_date
            })
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
            },
            "body": json.dumps(f"Error retrieving data: {str(e)}")
        }
