import news_api
import simplejson

body = {
    'id': 1,
    'type': 'test'
}
event = {
    'body': simplejson.dumps(body)
}
result = news_api.aws_add_fav(event, None)
print(result)