import requests
import boto3
from botocore.config import Config
from datetime import datetime
import time
import os

def get_client():
    config = Config(region_name=os.environ['AWS_REGION'])
    return boto3.client('dynamodb', endpoint_url='http://localhost:8000', config=config)

def process_response(ids, type):
    for i in range(1,10):
        fetch_news_item(ids[i], type)

def process_response_item(item, type):
    id = str(item['id'])
    title = item["title"]
    create_ts = int(item['time'])
    date_string = datetime.utcfromtimestamp(create_ts).strftime('%Y-%m-%d %H:%M:%S')
    url = item["url"]
    item = {
        'id': {
            'N': id
        },
        'title': {
            'S': title
        },
        'date_string': {
            'S': date_string
        },
        'create_ts': {
            'N': str(create_ts)
        },
        'update_ts': {
            'N': str(int(time.time()))
        },
        'type': {
            'S': type
        },
        'url': {
            'S': url
        }
    }
    dynamodb.put_item(TableName='hacker_news', Item=item)


def fetch_news_item(id, type):
    url = "https://hacker-news.firebaseio.com/v0/item/{}.json?print=pretty".format(id)
    response = requests.get(url)
    if response.status_code == 200:
        process_response_item(response.json(), type)
    else:
        raise Exception("Failed fetching item='{}' with status='{}' and message='{}' to url='{}'", id, response.status_code, response.text, url)

def fetch_news(type):
    url = "https://hacker-news.firebaseio.com/v0/{}.json?print=pretty".format(type)
    response = requests.get(url)
    if response.status_code == 200:
        process_response(response.json(), type)
    else:
        raise Exception("Request failed with status='{}' and message='{}' to url='{}'".format(response.status_code, response.text, url))

def fetch_top_news():
    fetch_news('topstories')

def fetch_new_news():
    fetch_news('newstories')

def fetch_best_news():
    fetch_news('beststories')


dynamodb = get_client()
fetch_top_news()
fetch_best_news()
fetch_new_news()