import main_function


def query_latest_news(type):
    table = dynamodb.Table('hacker_news')
    response = table.query(IndexName='recently_updated_gsi',
                           ExpressionAttributeValues={':type': type},
                           KeyConditionExpression='#col_type = :type',
                           ExpressionAttributeNames={
                             "#col_type": "type"
                           },
                           Limit=10,
                           ScanIndexForward=False)
    result = []
    for i in response['Items']:
        item = table.get_item(Key={'id': i['id'], 'type': i['type']})
        result.append(item['Item'])
    return result


def prepare_news():
    topstories = query_latest_news('topstories')
    newstories = query_latest_news('newstories')
    beststories = query_latest_news('beststories')


dynamodb = main_function.get_client()
