resource "null_resource" "prevent_destroy" {
  depends_on = [
    aws_instance.gitlab[0],
  ]
  lifecycle {
    prevent_destroy = true
  }
}
