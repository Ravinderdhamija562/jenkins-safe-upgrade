terraform {
  backend "s3" {
    bucket        = "jenkins-tfstate"
    region        = "us-east-1"
    encrypt       = true
    use_lockfile  = true
  }
}