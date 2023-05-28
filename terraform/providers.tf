provider "aws" {
 region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "bucketforbackend280523"
    key            = "my-terraform-state/terraform.tfstate"
    region         = "us-east-1"
  }
}




