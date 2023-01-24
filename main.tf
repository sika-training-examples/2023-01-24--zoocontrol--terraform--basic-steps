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
    NANO  = "t3.nano"
    MICRO = "t3.micro"
  }
  suffix = random_string.suffix.result

  default_vm = {
    ami           = local.IMAGE.DEBIAN_11
    instance_type = local.SIZE.NANO
  }

  vms = {
    foo = merge(local.default_vm, {})
    bar = merge(local.default_vm, {
      instance_type = local.SIZE.MICRO
    })
  }

  gitlab_enabled = true
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

resource "aws_instance" "gitlab" {
  count = local.gitlab_enabled ? 1 : 0

  ami           = local.IMAGE.DEBIAN_11
  instance_type = local.SIZE.MICRO
  key_name      = aws_key_pair.default.key_name

  tags = {
    Name = "gitlab-${local.suffix}"
  }
}

output "gitlab_ip" {
  value = length(aws_instance.gitlab) == 1 ? aws_instance.gitlab[0].public_ip : null
}

resource "aws_instance" "example" {
  for_each = local.vms

  ami           = each.value.ami
  instance_type = each.value.instance_type
  key_name      = aws_key_pair.default.key_name

  tags = {
    Name = "example-${each.key}-${local.suffix}"
  }
}

resource "cloudflare_record" "example" {
  for_each = local.vms

  zone_id = local.sikademo_zone_id
  name    = aws_instance.example[each.key].tags.Name
  type    = "A"
  value   = aws_instance.example[each.key].public_ip
  proxied = false
}

output "ip_list" {
  value = [
    for instance in aws_instance.example : instance.public_ip
  ]
}

output "domain_list" {
  value = [
    for record in cloudflare_record.example : record.hostname
  ]
}

output "ip_map" {
  value = {
    for instance in aws_instance.example :
    instance.tags.Name => instance.public_ip
  }
}

output "domain_map" {
  value = {
    for record in cloudflare_record.example :
    record.hostname => record.hostname
  }
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
