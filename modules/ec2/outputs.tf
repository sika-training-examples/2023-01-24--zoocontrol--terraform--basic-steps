output "ip" {
  value = aws_instance.this.public_ip
}

output "domain" {
  value = cloudflare_record.this.hostname
}

output "aws_instance" {
  value = aws_instance.this
}

output "cloudflare_record" {
  value = cloudflare_record.this
}
