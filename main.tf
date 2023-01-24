terraform {
  backend "http" {}
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

provider "aws" {
  alias      = "west"
  region     = "eu-west-1"
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

  vms2 = {
    hello = merge(local.default_vm, {})
    doggo = merge(local.default_vm, {
      instance_type = local.SIZE.MICRO
    })
    kitty = merge(local.default_vm, {})
  }

  gitlab_enabled = true
  # gitlab_state   = "stopped"
  gitlab_state = "running"
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

  lifecycle {
    prevent_destroy = true
  }

  # delete_on_termination = false
  ami           = local.IMAGE.DEBIAN_11
  instance_type = local.SIZE.MICRO
  key_name      = aws_key_pair.default.key_name
  user_data     = <<EOF
#cloud-config
ssh_pwauth: yes
password: asdfasdf2020
chpasswd:
  expire: false
write_files:
- path: /html/index.html
  permissions: "0755"
  owner: root:root
  content: |
    <h1>Hello from Fake Gitlab</h1>
runcmd:
  - |
    apt update
    apt install -y curl sudo git nginx
    curl -fsSL https://ins.oxs.cz/slu-linux-amd64.sh | sudo sh
    cp /html/index.html /var/www/html/index.html
EOF
  tags = {
    Name = "gitlab-${local.suffix}"
  }
}

resource "aws_ec2_instance_state" "gitlab" {
  count = length(aws_instance.gitlab) == 1 ? 1 : 0

  instance_id = aws_instance.gitlab[0].id
  state       = local.gitlab_state
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

module "ec2--vms2" {
  # providers = {
  #   aws = aws.west
  # }
  source   = "./modules/ec2"
  for_each = local.vms2

  zone_id       = local.sikademo_zone_id
  name          = each.key
  ami           = each.value.ami
  instance_type = each.value.instance_type
  key_name      = aws_key_pair.default.key_name
}

output "ec2--vms2--ips" {
  value = [
    for m in module.ec2--vms2 : m.ip
  ]
}

module "ec2--xxx" {
  source  = "gitlab.sikalabs.com/examples/ec2/aws"
  version = "0.1.0"

  zone_id  = local.sikademo_zone_id
  name     = "xxx"
  key_name = aws_key_pair.default.key_name
}
