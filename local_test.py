import news_api

event = {
    'type': 'newstories',
    'page': 10
}
news_api.aws_fetch_news(event, None)