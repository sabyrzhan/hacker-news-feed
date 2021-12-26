import json
import os
import time
from datetime import datetime

import boto3
import requests

import fetch_news

TELEGRAM_TARGET_CHAT_ID = "SPECIFY_TARGET_CHAT_ID"

if "TELEGRAM_TARGET_CHAT_ID" in os.environ:
    TELEGRAM_TARGET_CHAT_ID = os.environ["TELEGRAM_TARGET_CHAT_ID"]


def get_tg_token():
    if "LOCAL" not in os.environ:
        session = boto3.session.Session()
        client = session.client(
            service_name="secretsmanager",
            region_name="us-east-1"
        )
        get_secret_value_response = client.get_secret_value(
            SecretId="TelegramSecrets"
        )

        secret = get_secret_value_response['SecretString']
        j = json.loads(secret)
        token = j['TELEGRAM_TOKEN']
    else:
        if "TELEGRAM_TOKEN" in os.environ:
            token = os.environ["TELEGRAM_TOKEN"]
        else:
            token = "SPECIFY_TOKEN"

    return token


def query_latest_news(type, limit=10):
    table = dynamodb.Table('hacker_news')
    response = table.query(IndexName='recently_updated_gsi',
                           ExpressionAttributeValues={':type': type},
                           KeyConditionExpression='#col_type = :type',
                           ExpressionAttributeNames={
                             "#col_type": "type"
                           },
                           Limit=limit,
                           ScanIndexForward=False)
    result = []
    for i in response['Items']:
        item = table.get_item(Key={'id': i['id'], 'type': i['type']})
        result.append(item['Item'])
    return result


def build_tg_url(method):
    return "https://api.telegram.org/bot{}/{}".format(get_tg_token(), method)


def get_tg_me():
    url = build_tg_url("getMe")
    response = requests.get(url)

    json_formatted_str = json.dumps(response.json(), indent=2)
    print(json_formatted_str)
    return


def get_tg_updates():
    url = build_tg_url("getUpdates")
    response = requests.get(url)

    json_formatted_str = json.dumps(response.json(), indent=2)
    print(json_formatted_str)
    return


def send_telegram_message():
    url = build_tg_url("sendMessage")

    topstories_html = prepare_news_message_html(query_latest_news('topstories', limit=30))
    newstories_html = prepare_news_message_html(query_latest_news('newstories', limit=30))
    beststories_html = prepare_news_message_html(query_latest_news('beststories'))

    text = """
<b>Updates from HackerNews for {}</b>

<b>Top stories</b>
==================
{}

<b>Best stories</b>
==================
{}

<b>New stories</b>
==================
{}
""".format(datetime.utcfromtimestamp(time.time()).strftime('%d.%m.%Y'),
           topstories_html,
           beststories_html,
           newstories_html)

    request_data = {
        "chat_id" : TELEGRAM_TARGET_CHAT_ID,
        "parse_mode": "html",
        "text": text,
        "disable_web_page_preview": True
    }
    response = requests.post(url, json=request_data)

    json_formatted_str = json.dumps(response.json(), indent=2)
    print(json_formatted_str)


def prepare_news_message_html(messages):
    html = ""
    for message in messages:
        text = """
<a href="{}">{}</a>
        """.format(message['url'], message['title'])
        html += text
    return html


def aws_send_news(event, context):
    send_telegram_message()


dynamodb = fetch_news.get_client()
