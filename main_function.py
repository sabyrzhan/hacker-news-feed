import requests
import boto3
from botocore.config import Config
from datetime import datetime
import time
import os

def get_client():
    config = Config(region_name=os.environ['AWS_REGION'])
    if 'LOCAL' in os.environ:
        return boto3.client('dynamodb', endpoint_url='http://localhost:8000', config=config)
    else:
        return boto3.client('dynamodb')

def process_response(ids, type):
    for i in range(1,20):
        fetch_news_item(ids[i], type)

def process_response_item(item, type):
    id = str(item['id'])
    title = item["title"]
    create_ts = int(item['time'])
    date_string = datetime.utcfromtimestamp(create_ts).strftime('%Y-%m-%d %H:%M:%S')
    url = item["url"] if "url" in item else "https://news.ycombinator.com/item?id={}".format(id)
    existing = dynamodb.get_item(TableName='hacker_news', Key={'id': {'N': id}, 'type': {'S': type}})
    if "Item" not in existing:
        item = {}
    else:
        item = existing['Item']

    item['id'] = {'N': id}
    item['title'] = {'S': title}
    item['date_string'] = {'S': date_string}
    item['create_ts'] = {'N': str(create_ts)}
    item['update_ts'] = {'N': str(int(time.time()))}
    item['type'] = {'S': type}
    item['url'] = {'S': url}

    if int(id) == 29636863:
        print(item)

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