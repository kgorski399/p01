
resource "aws_dynamodb_table" "farm" {
  name           = "Farm"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "farm_id"

  attribute {
    name = "farm_id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }
}