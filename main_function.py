import requests
import boto3
from datetime import datetime

def process_response(ids):
    for i in range(1,10):
        fetch_news_item(ids[i])

def process_response_item(item):
    id = str(item['id'])
    title = item["title"]
    create_ts = int(item['time'])
    date_string = datetime.utcfromtimestamp(create_ts).strftime('%Y-%m-%d %H:%M:%S')
    url = item["url"]
    dynamodb = boto3.client('dynamodb')
    existing = dynamodb.get_item(TableName='hacker_news', Key={'id': {'S': id}})
    if existing is None:
        dynamodb.put_item(TableName='hacker_news', Item={'title': {'S': title}, 'date_string': {'S': date_string}, 'create_ts': {'N': create_ts}, 'url': {'S': url}})


def fetch_news_item(id):
    url = "https://hacker-news.firebaseio.com/v0/item/{}.json?print=pretty".format(id)
    response = requests.get(url)
    if response.status_code == 200:
        process_response_item(response.json())
    else:
        raise Exception("Failed fetching item='{}' with status='{}' and message='{}'", id, response.status_code, response.text)

def fetch_news(type):
    url = "https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty"
    response = requests.get(url)
    if response.status_code == 200:
        process_response(response.json())
    else:
        raise Exception("Request failed with status='{}' and message='{}'".format(response.status_code, response.text))


fetch_news("fom")