terraform {
  backend "s3" {
    bucket = "aws-terraform-remotebackend"
    key    = "tfstate/devops-homework-cau3.tfstate"
    region = "ap-southeast-1"
  }
}
