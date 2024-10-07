import json
import boto3
from datetime import datetime, timezone

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
ssm = boto3.client('ssm')
table = dynamodb.Table('Farm')

def get_farm_id():
    response = ssm.get_parameter(Name='farm_id')
    return response['Parameter']['Value']

def lambda_handler(event, context):
    farm_id = get_farm_id()

    response = table.get_item(Key={'farm_id': farm_id})
    item = response.get('Item', {})

    if not item:
        raise Exception("Farm not found.")

    last_fed = item.get('feedDate')
    last_watered = item.get('waterDate')

    if not last_fed or not last_watered:
        raise Exception("Missing feedDate or waterDate in the farm data.")

    now = datetime.now(timezone.utc)

    last_fed_time = datetime.fromisoformat(last_fed)
    if last_fed_time.tzinfo is None:
        last_fed_time = last_fed_time.replace(tzinfo=timezone.utc)

    last_watered_time = datetime.fromisoformat(last_watered)
    if last_watered_time.tzinfo is None:
        last_watered_time = last_watered_time.replace(tzinfo=timezone.utc)

    minutes_since_fed = (now - last_fed_time).total_seconds() / 60
    minutes_since_watered = (now - last_watered_time).total_seconds() / 60

    minutes_since_care = max(minutes_since_fed, minutes_since_watered)

    intervals_since_care = int(minutes_since_care // 5)

    satisfaction = max(0, 100 - (intervals_since_care * 5))

    satisfaction = int(round(satisfaction))

    satisfaction = min(satisfaction, 100)

    if item.get('satisfaction') != satisfaction:
        table.update_item(
            Key={'farm_id': farm_id},
            UpdateExpression='SET satisfaction = :s',
            ExpressionAttributeValues={':s': satisfaction}
        )

    return {
        "satisfaction": satisfaction
    }
