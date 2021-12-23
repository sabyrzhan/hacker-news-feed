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
5. Execute `get_tg_updates()` method in `send_news.py`. From response get `chat_id` of your channel.
6. Set chat_id as target chat id in `.env` and `terraform/main.tf` files

## Requirements
* AWS account
* Python 3 (dependencies are in `requiremenets.txt`)
* Docker (to run local `dynamodb`)
* Terraform (to provision AWS resources)

## Usage
* Create `venv` with `python -m venv`
* Install requirements with `pip3 install -r requirements.txt`
* Use `docker-compose.yml` to run local `dynamodb` and `dynamodb-admin`
* Use `terraform` to create AWS resources and upload/update lambda function.
  * `./terraform.sh -chdir=<folder_name> <terraform parameters>`
* For local development - set environment variables by copying `.env.example` to `.env` file and 
setting env variable values. On AWS environment - AWS Secret Manager is used to store the same variables.

## Secrets on AWS Secret Manager
1. Goto Secret Manager in Console
2. Add variables from `.env` file
3. Name the secret `TelegramSecrets`
  
## Resources
* Local DynamoDB: https://github.com/aws-samples/aws-sam-java-rest
* DynamoDB admin panel: https://github.com/aaronshaf/dynamodb-admin
* Terraform and Lambda: https://medium.com/swlh/deploy-aws-lambda-and-dynamodb-using-terraform-6e04f62a3165
* AWS terraform docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
* Schedule Lambda task with EventBridge:
https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-run-lambda-schedule.html
* AWS Lambda runtimes: https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html
* Regarding message sending in Telegram Bot:
  * https://stackoverflow.com/questions/41174831/telegram-bot-chat-not-found
  * https://medium.com/javarevisited/sending-a-message-to-a-telegram-channel-the-easy-way-eb0a0b32968
* AWS Secret Manager:
  * https://docs.aws.amazon.com/mediaconnect/latest/ug/iam-policy-examples-asm-secrets.html
  * https://stackoverflow.com/questions/51537795/accessdenied-on-dynamodb-gsi-index
  * https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/iam-policy-specific-table-indexes.html
  * https://aws.amazon.com/blogs/security/how-to-securely-provide-database-credentials-to-lambda-functions-by-using-aws-secrets-manager/