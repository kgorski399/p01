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
                "body": json.dumps("Farm not found")
            }

        item = response['Item']
        current_animal_count = item.get('animal_count', 0)
        if current_animal_count > 0:
            new_animal_count = current_animal_count - 1
        else:
            new_animal_count = 0

        table.update_item(
            Key={'farm_id': farm_id},
            UpdateExpression="set animal_count = :a",
            ExpressionAttributeValues={':a': new_animal_count}
        )

        return {
            "statusCode": 200,
            "body": json.dumps({
                "farm_id": farm_id,
                "animal_count": new_animal_count
            })
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps(f"Error updating data: {str(e)}")
        }
