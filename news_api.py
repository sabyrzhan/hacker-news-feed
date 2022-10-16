import fetch_news
import base64
import simplejson
from send_news import query_latest_news, query_latest_news_pagination


def fetch_news_from_db(type, page):
    news = query_latest_news_pagination(type, limit=30, page=page)
    return news

def decode64_string(base64_string):
    base64_bytes = base64_string.encode("ascii")
    sample_string_bytes = base64.b64decode(base64_bytes)
    sample_string = sample_string_bytes.decode("ascii")

    return sample_string

def encode64_string(object):
    json_string = simplejson.dumps(object)
    sample_string_bytes = json_string.encode("ascii")

    base64_bytes = base64.b64encode(sample_string_bytes)
    base64_string = base64_bytes.decode("ascii")

    return base64_string

def aws_fetch_news(event, context):
    type = event['queryStringParameters']['type']
    page = event['queryStringParameters']['page'] if 'page' in event['queryStringParameters'] else None
    if page is not None:
        page = decode64_string(page)
        page = simplejson.loads(page)

    news = fetch_news_from_db(type, page)
    news['page'] = encode64_string(news['page'])

    return {
        "statusCode": 200,
        "body": simplejson.dumps(news)
    }


dynamodb = fetch_news.get_client()