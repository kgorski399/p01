terraform {
  backend "s3" {
    bucket         = "terraform-farm-states"
    key            = "dev.tfstate" # Ścieżka do pliku stanu (można personalizować dla różnych folderów/projektów)
    region         = "us-east-1"                
    encrypt        = true                       # Włączenie szyfrowania w S3
  }
}
