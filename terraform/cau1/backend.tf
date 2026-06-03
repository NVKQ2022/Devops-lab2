terraform {
  backend "s3" {
    bucket = "aws-terraform-remotebackend"
    key    = "tfstate/devops-homework-cau1.tfstate"
    region = "ap-southeast-1"
  }
}
