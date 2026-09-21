terraform {
  required_version = ">= 1.5.0"



  backend "s3" {
    bucket       = "org-tfstate-landing-zone-management"
    key          = "landing-zone/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}