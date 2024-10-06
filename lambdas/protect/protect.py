import boto3

ssm = boto3.client('ssm')

def get_api_id():
    response = ssm.get_parameter(Name='api_id')
    return response['Parameter']['Value']

def lambda_handler(event, context):
    client = boto3.client('apigateway')
    api_id = get_api_id() 
    response = client.delete_rest_api(restApiId=api_id)
    return {
        'statusCode': 200,
        'body': 'API Gateway deleted successfully'
    }

