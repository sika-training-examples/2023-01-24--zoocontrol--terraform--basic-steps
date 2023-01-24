terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.51.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "3.32.0"
    }
  }
}
