import json
import boto3
from datetime import datetime

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table = dynamodb.Table('Farm')

def lambda_handler(event, context):
    farm_id = event['farm_id']  
    action = event.get('action') 

    if action == 'water':
        update_field = 'waterDate'
    elif action == 'feed':
        update_field = 'feedDate'
    else:
        return {
            "statusCode": 400,
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
        "body": json.dumps(f"Successfully updated {update_field}")
    }

