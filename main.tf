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
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
}

variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "aws" {
  region     = "eu-central-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

variable "cloudflare_api_token" {}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "random" {}

locals {
  sikademo_zone_id = "f2c00168a7ecd694bb1ba017b332c019"
  IMAGE = {
    DEBIAN_11 = "ami-0c75b861029de4030"
  }
  SIZE = {
    SMALL = "t3.nano"
  }
  suffix = random_string.suffix.result
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "random_password" "password" {
  length           = 10
  special          = true
  override_special = "_"
}

resource "aws_key_pair" "default" {
  key_name   = "ondrejsika-${local.suffix}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCslNKgLyoOrGDerz9pA4a4Mc+EquVzX52AkJZz+ecFCYZ4XQjcg2BK1P9xYfWzzl33fHow6pV/C6QC3Fgjw7txUeH7iQ5FjRVIlxiltfYJH4RvvtXcjqjk8uVDhEcw7bINVKVIS856Qn9jPwnHIhJtRJe9emE7YsJRmNSOtggYk/MaV2Ayx+9mcYnA/9SBy45FPHjMlxntoOkKqBThWE7Tjym44UNf44G8fd+kmNYzGw9T5IKpH1E1wMR+32QJBobX6d7k39jJe8lgHdsUYMbeJOFPKgbWlnx9VbkZh+seMSjhroTgniHjUl8wBFgw0YnhJ/90MgJJL4BToxu9PVnH"
}

resource "aws_instance" "example" {
  ami           = local.IMAGE.DEBIAN_11
  instance_type = local.SIZE.SMALL
  key_name      = aws_key_pair.default.key_name

  tags = {
    Name = "example-${local.suffix}"
  }
}

resource "cloudflare_record" "example" {
  zone_id = local.sikademo_zone_id
  name    = aws_instance.example.tags.Name
  type    = "A"
  value   = aws_instance.example.public_ip
  proxied = true
}

output "ip" {
  value = aws_instance.example.public_ip
}

output "domain" {
  value = cloudflare_record.example.hostname
}

data "aws_instance" "example" {
  instance_id = aws_instance.example.id
}

output "ip_ds" {
  value = data.aws_instance.example.public_ip
}

output "password" {
  value     = sensitive(nonsensitive(random_password.password.result))
  sensitive = true
}

output "list" {
  value = [0, 1, 2]
}

output "map" {
  value = {
    foo = 1
    bar = 2
  }
}
