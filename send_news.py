import main_function
from boto3.dynamodb.conditions import Key

def query_latest_news(type):
    table = dynamodb.Table('hacker_news')
    response = table.query(IndexName='recently_updated_gsi',
                           ExpressionAttributeValues={
                                ':tp': {
                                    'S': type
                                }
                              },
                              KeyConditionExpression='#col_type = :tp',
                              ExpressionAttributeNames={
                                "#col_type": "type"
                              },
                              Limit=10,
                              ScanIndexForward=False)
    result = []
    for i in response['Items']:
        pass #item = table.get_item(TableName='')
    pass


dynamodb = main_function.get_client()