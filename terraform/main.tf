terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "kz.sabyrzhan.terraform.backend"
    key    = "hacker_news_feed/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

data "archive_file" "mainzip" {
  type = "zip"
  source_dir = "${path.module}/../venv/lib/python3.9/site-packages"
  output_path = "${path.module}/../main.zip"
}

resource "aws_lambda_function" "fetch_news_function" {
  filename = "${path.module}/../main.zip"
  function_name = "main_function"
  role = aws_iam_role.hacker_news_lambda_role.arn
  handler = "main_function.aws_fetch_news_function"
  runtime = "python3.9"
  source_code_hash = "data.archive_file.mainzip.output_base64sha256"
  timeout = 120
}

resource "aws_dynamodb_table" "hacker_news_table" {
  name           = "hacker_news"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "id"
  range_key      = "type"

  attribute {
    name = "id"
    type = "N"
  }

  attribute {
    name = "type"
    type = "S"
  }
}

resource "aws_iam_role_policy" "access_table_policy" {
  name = "access_table_policy"
  role = aws_iam_role.hacker_news_lambda_role.id
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
      "Resource": "${aws_dynamodb_table.hacker_news_table.arn}"
   }
  ]
}
EOF
}

resource "aws_iam_role" "hacker_news_lambda_role" {
  name = "hacker_news_lambda_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_lambda_permission" "add_permission_to_fetch_news_function" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fetch_news_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.fetch_news_rule.arn
}

resource "aws_cloudwatch_event_rule" "fetch_news_rule" {
  name        = "fetch_news_rule"
  description = "fetch_news rule (includes top, best and new)"
  schedule_expression = "rate(10 minutes)"
}

resource "aws_cloudwatch_event_target" "fetch_news_target" {
  arn  = aws_lambda_function.fetch_news_function.arn
  target_id = "fetch_news"
  rule = aws_cloudwatch_event_rule.fetch_news_rule.name
}