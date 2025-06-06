# Bucket stuff
resource "aws_s3_bucket" "expenseflow_assets" {
  bucket = "expenseflow-assets"
}

resource "aws_s3_bucket_ownership_controls" "expenseflow_assets" {
  bucket = aws_s3_bucket.expenseflow_assets.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "expenseflow_assets" {
  bucket = aws_s3_bucket.expenseflow_assets.id

  block_public_acls       = true
  block_public_policy     = false # pub access via bucket policy
  ignore_public_acls      = true
  restrict_public_buckets = false # pub access via policy
}

# Public access stuff
data "aws_iam_policy_document" "public_assets" {
  statement {
    sid     = "AllowPublicReadOnPublicFolder"
    effect  = "Allow"
    actions = ["s3:GetObject"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "${aws_s3_bucket.expenseflow_assets.arn}/public/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "public_assets_policy" {
  bucket = aws_s3_bucket.expenseflow_assets.id
  policy = data.aws_iam_policy_document.public_assets.json
}

# Assets
resource "aws_s3_object" "auth0_logo" {
  bucket       = aws_s3_bucket.expenseflow_assets.bucket
  key          = "public/auth0_logo.png"
  source       = "../assets/auth0_logo.png"
  content_type = "image/png"
}
