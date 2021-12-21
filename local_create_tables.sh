#!/bin/bash

export AWS_ACCESS_KEY_ID=local
export AWS_SECRET_ACCESS_KEY=local
export AWS_REGION=local

do_get() {
  echo "Getting:"
  aws dynamodb get-item \
      --table-name 'hacker_news'  \
      --key '{"id": {"N": "1"}}' \
      --endpoint-url http://localhost:8000
}

do_add() {
  echo "Adding:"
  aws dynamodb put-item \
    --table-name 'hacker_news'  \
    --item \
        '{"id": {"N": "1"}, "type": {"S": "test"}}' \
    --endpoint-url http://localhost:8000
}

do_scan() {
  echo "Scanning:"
  aws dynamodb \
    scan --table-name hacker_news  \
    --endpoint-url http://localhost:8000
}

do_create_table() {
  echo "Creating table:"
  aws dynamodb \
    create-table --table-name hacker_news  \
    --attribute-definitions \
        AttributeName=id,AttributeType=N \
        AttributeName=type,AttributeType=S \
    --key-schema \
        AttributeName=id,KeyType=HASH \
        AttributeName=type,KeyType=RANGE \
    --billing-mode PAY_PER_REQUEST \
    --endpoint-url http://localhost:8000
}

do_list_tables() {
    echo "Listing tables:"
    aws dynamodb \
        list-tables \
        --endpoint-url http://localhost:8000
}

do_delete() {
  echo "Deleting item:"
  aws dynamodb delete-item --table-name hacker_news  \
    --key '{"id": {"N": "1"}}' \
    --endpoint-url http://localhost:8000
}

do_delete_table() {
  echo "Deleting table:"
  aws dynamodb delete-table \
    --table-name 'hacker_news'  \
    --endpoint-url http://localhost:8000
}

POSITIONAL=()
ACTION="get"
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -a|--action)
      ACTION="$2"
      shift # past argument
      shift # past value
      ;;
    *)    # unknown option
      echo "Unknown parameter: $key"
      exit
      ;;
  esac
done

set -- "${POSITIONAL[@]}" # restore positional parameters

case $ACTION in
  "get")
    do_get
  ;;
  "del")
    do_delete
  ;;
  "dtable")
    do_delete_table
  ;;
  "create")
    do_create_table
  ;;
  "list")
    do_list_tables
  ;;
  "scan")
    do_scan
  ;;
  "add")
    do_add
  ;;
  *)
    echo "Unknown action: $ACTION"
    exit
  ;;
esac