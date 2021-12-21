import requests
import boto3
from botocore.config import Config
from datetime import datetime
import time
import os

def get_client():
    config = Config(region_name=os.environ['AWS_REGION'])
    if 'LOCAL' in os.environ:
        return boto3.resource('dynamodb', endpoint_url='http://localhost:8000', config=config)
    else:
        return boto3.resource('dynamodb')

def process_response(ids, type):
    for i in range(1,20):
        fetch_news_item(ids[i], type)

def process_response_item(item, type):
    id = item['id']
    title = item["title"]
    create_ts = int(item['time'])
    date_string = datetime.utcfromtimestamp(create_ts).strftime('%Y-%m-%d %H:%M:%S')
    url = item["url"] if "url" in item else "https://news.ycombinator.com/item?id={}".format(id)
    table = dynamodb.Table('hacker_news')
    existing = table.get_item(Key={'id': id, 'type': type})
    if "Item" not in existing:
        item = {}
    else:
        item = existing['Item']

    item['id'] = id
    item['title'] = title
    item['date_string'] = date_string
    item['create_ts'] = create_ts
    item['update_ts'] = int(time.time())
    item['type'] = type
    item['url'] = url

    table.put_item(Item=item)


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
    print("Starting to fetch top news...")
    fetch_news('topstories')
    print("Finished top news fetching!")

def fetch_new_news():
    print("Starting to fetch new news...")
    fetch_news('newstories')
    print("Finished new news fetching!")

def fetch_best_news():
    print("Starting to fetch best news...")
    fetch_news('beststories')
    print("Finished best news fetching!")


def aws_fetch_news_function(event, context):
    fetch_top_news()

dynamodb = get_client()