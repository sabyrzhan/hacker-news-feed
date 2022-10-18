import fetch_news
import base64
import simplejson
import send_news


def fetch_news_from_db(type, page):
    news = send_news.query_latest_news_pagination(type, limit=30, page=page)
    return news


def make_post_fav(post_id, type):
    return fetch_news.set_item_fav(post_id, type)


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


def aws_add_fav(event, context):
    json_body = event['body']
    post_data = simplejson.loads(json_body)
    id = post_data['id'] if 'id' in post_data else ''
    type = post_data['type'] if 'type' in post_data else ''
    if id == '':
        return {
            "statusCode": 400,
            "body": '{"message": "id not specified"}'
        }
    if type == '':
        return {
            "statusCode": 400,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": '{"message": "type not specified"}'
        }

    added_item = make_post_fav(id, type)
    if added_item is None:
        return {
            "statusCode": 404,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": '{"message": "Item not found"}'
        }
    else:
        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": simplejson.dumps(added_item)
        }



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
        "headers": {
            "Content-Type": "application/json"
        },
        "body": simplejson.dumps(news)
    }

def aws_fetch_favs(event, context):
    params = event['queryStringParameters'] if event is not None and 'queryStringParameters' in event else {}
    page = params['page'] if params is not None and 'page' in params else None
    if page is not None and page != '':
        page = decode64_string(page)
        page = simplejson.loads(page)

    news = send_news.query_favs_pagination(limit=30, page=page)
    if news['page'] is not None:
        news['page'] = encode64_string(news['page'])

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": simplejson.dumps(news)
    }
