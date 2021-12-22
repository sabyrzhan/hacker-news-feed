# 📝 👨‍💻 📰 Subscribe to HackerNews Feed using Telegram Bot

## About
Send HackerNews feed as Telegram message to user at the end-of-the-day.

## The flow
Because Telegram bot naturally is unable to send message to user directly, we can use channel so the bot will send 
message to channel where user was added. To achieve this:
1. Create telegram bot
2. Create private channel and add telegram bot as administrator
3. Set Telegram token in `.env` file
4. Send test message to bot from channel in Telegram
5. Execute `get_tg_me()` method in `send_news.py`. From response get `chat_id` of your channel.
6. Set chat_id as target chat id in `.env` file

## Requirements
* AWS account
* Python 3 (dependencies are in `requiremenets.txt`)
* Docker (to run local `dynamodb`)
* Terraform (to provision AWS resources)

## Usage
* Use `docker-compose.yml` to run local `dynamodb` and `dynamodb-admin`
* Use `terraform` to create AWS resources and upload/update lambda function.
  * `./terraform.sh -chdir=<folder_name> <terraform parameters>`
* Set environment variables by copying `.env.example` to `.env` file and setting env variable values
  
## Resources
* Local DynamoDB: https://github.com/aws-samples/aws-sam-java-rest
* DynamoDB admin panel: https://github.com/aaronshaf/dynamodb-admin
* Terraform and Lambda: https://medium.com/swlh/deploy-aws-lambda-and-dynamodb-using-terraform-6e04f62a3165
* AWS terraform docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
* Schedule Lambda task with EventBridge:
https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-run-lambda-schedule.html
* AWS Lambda runtimes: https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html