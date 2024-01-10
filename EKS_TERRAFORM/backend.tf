terraform {
  backend "s3" {
    bucket = "tommybuc111" # Replace with your actual S3 bucket name
    key    = "EKS-hot/terraform.tfstate"
    region = "us-east-1"
  }
}
