provider "aws" {
  region = "us-east-1" 
}

resource "aws_dynamodb_table" "farm" {
  name         = "Farm"
  billing_mode = "PROVISIONED" # Ustawiony tryb provisioned


  read_capacity  = 1  # Liczba odczytów na sekundę
  write_capacity = 1  # Liczba zapisów na sekundę

  hash_key = "farm_id"  # Klucz partycji

  attribute {
    name = "farm_id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }
}
