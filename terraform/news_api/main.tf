terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "kz.sabyrzhan.terraform.backend"
    key    = "hacker_news_feed/terraform_news_api.tfstate"
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

data "aws_iam_role" "hacker_news_lambda_role" {
  name = "hacker_news_lambda_role"
}

resource "aws_lambda_function" "news_api_function" {
  filename = "${local.source_root}/main.zip"
  function_name = "news_api"
  role = data.aws_iam_role.hacker_news_lambda_role.arn
  handler = "news_api.aws_fetch_news"
  runtime = "python3.9"
  source_code_hash = "data.archive_file.mainzip.output_base64sha256"
  timeout = 120
}

resource "aws_lambda_function" "news_api_fav_function" {
  filename = "${local.source_root}/main.zip"
  function_name = "news_api_fav"
  role = data.aws_iam_role.hacker_news_lambda_role.arn
  handler = "news_api.aws_add_fav"
  runtime = "python3.9"
  source_code_hash = "data.archive_file.mainzip.output_base64sha256"
  timeout = 120
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