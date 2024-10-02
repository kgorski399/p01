terraform {
  backend "s3" {
    bucket  = "terraform-farm-states"
    key     = "dev.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
