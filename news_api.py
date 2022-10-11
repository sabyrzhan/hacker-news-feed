import fetch_news
from send_news import query_latest_news, query_latest_news_pagination


def fetch_news_from_db(type, page):
    news = query_latest_news_pagination(type, page=page)
    return news


def aws_fetch_news(event, context):
    type = event['queryStringParameters']['type']
    page = event['queryStringParameters']['page']
    return fetch_news_from_db(type, page)


dynamodb = fetch_news.get_client()