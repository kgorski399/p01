terraform {
  backend "s3" {
    bucket         = var.s3_bucket
    key            = "dev.tfstate" # Ścieżka do pliku stanu (można personalizować dla różnych folderów/projektów)
    region         = "us-east-1"                
    encrypt        = true                       # Włączenie szyfrowania w S3
  }
}
