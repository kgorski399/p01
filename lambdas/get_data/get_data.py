import json
import boto3

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table = dynamodb.Table('Farm')

def lambda_handler(event, context):
    farm_id = event['queryStringParameters']['farm_id']  
    
    try:
        response = table.get_item(
            Key={'farm_id': farm_id}
        )
        
        if 'Item' not in response:
            return {
                "statusCode": 404,
                "body": json.dumps("Farm not found")
            }

        item = response['Item']
        water_date = item.get('waterDate', 'Not available')
        feed_date = item.get('feedDate', 'Not available')

        return {
            "statusCode": 200,
            "body": json.dumps({
                "farm_id": farm_id,
                "last_watered": water_date,
                "last_fed": feed_date
            })
        }
    
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps(f"Error retrieving data: {str(e)}")
        }
