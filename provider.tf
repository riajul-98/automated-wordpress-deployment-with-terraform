terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0.0-beta2"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "5.5.0"
    }
  }

    

  backend "s3" {
    bucket = "terraform-state-riajul"
    key    = "terraform.tfstate"
    region = "eu-west-2"
  }
}

provider "cloudflare" {
  
}