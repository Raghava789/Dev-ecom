/*resource "aws_dynamodb_table" "state-lock-dynamodb-table" {
  name           = var.state-lock-dynamodb-table-name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockId"

  attribute {
    name = "LockId"
    type = "S"
  }

}*/