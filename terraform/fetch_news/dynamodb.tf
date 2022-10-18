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

  attribute {
    name = "update_ts"
    type = "N"
  }

  global_secondary_index {
    hash_key        = "type"
    range_key       = "update_ts"
    name            = "recently_updated_gsi"
    projection_type = "INCLUDE"
    non_key_attributes = ["id"]
    read_capacity = 5
    write_capacity = 5
  }
}

resource "aws_dynamodb_table" "hacker_news_favs_table" {
  name           = "hacker_news_favs"
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

  attribute {
    name = "update_ts"
    type = "N"
  }

  global_secondary_index {
    hash_key        = "type"
    range_key       = "update_ts"
    name            = "hacker_news_favs_gsi"
    projection_type = "INCLUDE"
    non_key_attributes = ["id"]
    read_capacity = 5
    write_capacity = 5
  }
}