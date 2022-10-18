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

locals {
  source_root = "${path.module}/../.."
  site_packages_root = "${local.source_root}/venv/tmp/python/site-packages"
}

data "archive_file" "mainzip" {
  type = "zip"
  source_dir = local.site_packages_root
  output_path = "${local.source_root}/main.zip"
}

resource "aws_lambda_function" "fetch_news_function" {
  filename = "${local.source_root}/main.zip"
  function_name = "fetch_news"
  role = aws_iam_role.hacker_news_lambda_role.arn
  handler = "fetch_news.aws_fetch_news_function"
  runtime = "python3.9"
  source_code_hash = "data.archive_file.mainzip.output_base64sha256"
  timeout = 120
}

resource "aws_iam_role_policy" "access_hacker_news_table_policy" {
  name = "access_hacker_news_table_policy"
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
      "Resource": [
        "${aws_dynamodb_table.hacker_news_table.arn}",
        "${aws_dynamodb_table.hacker_news_table.arn}/index/*"
      ]
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
  schedule_expression = "rate(1 hour)"
}

resource "aws_cloudwatch_event_target" "fetch_news_target" {
  arn  = aws_lambda_function.fetch_news_function.arn
  target_id = "fetch_news"
  rule = aws_cloudwatch_event_rule.fetch_news_rule.name
}