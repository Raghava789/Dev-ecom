resource "aws_s3_bucket" "backend_s3" {
  bucket = var.backend_s3_name

  tags = {
    Name        = "remote_backend"
  }

  lifecycle {
    prevent_destroy = false
  }
}