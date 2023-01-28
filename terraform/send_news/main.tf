terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "kz.sabyrzhan.terraform.backend"
    key    = "hacker_news_feed/terraform_send_news.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  source_root = "${path.module}/../.."
  site_packages_root = "${local.source_root}/venv/tmp/python/site-packages"
  telegram_target_chat_id = "-1001766264771"
}

data "archive_file" "mainzip" {
  type = "zip"
  source_dir = local.site_packages_root
  output_path = "${local.source_root}/main.zip"
}

data "aws_iam_role" "hacker_news_lambda_role" {
  name = "hacker_news_lambda_role"
}

data "aws_secretsmanager_secret" "telegram_secret" {
  name = "TelegramSecrets"
}

resource "aws_lambda_function" "send_news_function" {
  filename = "${local.source_root}/main.zip"
  function_name = "send_news"
  role = data.aws_iam_role.hacker_news_lambda_role.arn
  handler = "send_news.aws_send_news"
  runtime = "python3.9"
  source_code_hash = "data.archive_file.mainzip.output_base64sha256"
  timeout = 120

  environment {
    variables = {
      TELEGRAM_TARGET_CHAT_ID = local.telegram_target_chat_id
    }
  }
}

resource "aws_lambda_permission" "add_permission_to_fetch_news_function" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.send_news_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.send_news_rule.arn
}

resource "aws_cloudwatch_event_rule" "send_news_rule" {
  name        = "send_news_rule"
  description = "send news rule (includes top, best and new)"
  schedule_expression = "cron(0 4 * * ? *)"
}

resource "aws_cloudwatch_event_target" "send_news_target" {
  arn  = aws_lambda_function.send_news_function.arn
  target_id = "send_news"
  rule = aws_cloudwatch_event_rule.send_news_rule.name
}

resource "aws_iam_role_policy" "access_secret_manager" {
  name = "access_secret_manager_policy"
  role = data.aws_iam_role.hacker_news_lambda_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement":[
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
      ],
      "Resource": "${data.aws_secretsmanager_secret.telegram_secret.arn}"
   }
  ]
}
EOF
}

data "aws_dynamodb_table" "hacker_news_table" {
  name = "hacker_news"
}

resource "aws_iam_role_policy" "access_table_policy" {
  name = "access_table_policy"
  role = data.aws_iam_role.hacker_news_lambda_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement":[
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:BatchGetItem",
        "dynamodb:GetItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:BatchWriteItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem"
      ],
      "Resource": [
        "${data.aws_dynamodb_table.hacker_news_table.arn}",
        "${data.aws_dynamodb_table.hacker_news_table.arn}/index/*"
      ]
   }
  ]
}
EOF
}