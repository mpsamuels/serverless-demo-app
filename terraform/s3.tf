resource "aws_s3_bucket" "upload_bucket" {
  bucket = "${var.prefix_name}-upload-bucket"
}

resource "aws_s3_bucket_acl" "upload_bucket_acl" {
  bucket = aws_s3_bucket.upload_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "upload_bucket_public_block" {
  bucket = aws_s3_bucket.upload_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "upload_bucket_cors" {
  bucket = aws_s3_bucket.upload_bucket.id
  cors_rule {
    allowed_headers = ["Content-Type"]
    allowed_methods = ["PUT"]
    allowed_origins = ["https://www.${var.domain_name}"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket      = aws_s3_bucket.upload_bucket.bucket
  eventbridge = true
}