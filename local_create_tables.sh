#!/bin/bash
aws dynamodb \
  create-table --table-name hacker_news  \
  --attribute-definitions AttributeName=id,AttributeType=N --key-schema AttributeName=id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --endpoint-url http://localhost:8000
