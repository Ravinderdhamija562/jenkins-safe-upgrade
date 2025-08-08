terraform {
  backend "s3" {
    bucket        = "ns-cicd-tfstate"
    key           = "ep-jenkins/common/terraform.tfstate"
    region        = "us-east-1"
    encrypt       = true
    use_lockfile  = true
  }
}