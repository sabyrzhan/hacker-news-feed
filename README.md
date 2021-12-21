# 📝 👨‍💻 📰 Subscribe to HackerNews Feed

## About
Send HackerNews as feed to user email at the end-of-the-day.

## Requirements
* AWS account
* Python 3 (dependencies are in `requiremenets.txt`)
* Docker (to run local `dynamodb`)
* Terraform (to provision AWS resources)

## Usage
* Use `docker-compose.yml` to run local `dynamodb` and `dynamodb-admin`
* Use `terraform` to create AWS resources and upload/update lambda function.
  * `./terraform.sh -chdir=<folder_name> <terraform parameters>`
  
## Resources
* Local DynamoDB: https://github.com/aws-samples/aws-sam-java-rest
* DynamoDB admin panel: https://github.com/aaronshaf/dynamodb-admin
* Terraform and Lambda: https://medium.com/swlh/deploy-aws-lambda-and-dynamodb-using-terraform-6e04f62a3165
* AWS terraform docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
* Schedule Lambda task with EventBridge:
https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-run-lambda-schedule.html
* AWS Lambda runtimes: https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html