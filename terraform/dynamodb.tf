resource "aws_dynamodb_table" "dynamo_db_rekognition_results" {
  name         = "${var.prefix_name}-rekognition"
  hash_key     = "FileName"
  range_key    = "Label"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "FileName"
    type = "S"
  }
  attribute {
    name = "Label"
    type = "S"
  }
  global_secondary_index {
    name               = "Labels"
    hash_key           = "Label"
    range_key          = "FileName"
    projection_type    = "ALL"
  }
}