resource "aws_instance" "this" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  user_data     = var.user_data
  tags = {
    Name = var.name
  }
}

resource "cloudflare_record" "this" {
  zone_id = var.zone_id
  name    = aws_instance.this.tags.Name
  type    = "A"
  value   = aws_instance.this.public_ip
  proxied = false
}
