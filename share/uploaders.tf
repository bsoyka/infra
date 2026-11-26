# One IAM user per uploading client (local.uploaders), each limited to writing
# under its own prefixes. Access keys are deliberately NOT managed here (they'd
# land in state in plaintext); create them with the CLI. See README.

resource "aws_iam_user" "uploader" {
  for_each = local.uploaders

  name = "${local.bucket_name}-${each.key}"
  path = "/share/"
}

data "aws_iam_policy_document" "uploader" {
  for_each = local.uploaders

  statement {
    sid = "WriteOwnPrefixes"
    actions = concat(
      ["s3:PutObject", "s3:AbortMultipartUpload"],
      each.value.delete ? ["s3:DeleteObject"] : [],
    )
    resources = [
      for p in each.value.prefixes : "${aws_s3_bucket.share.arn}/${local.prefixes[p].path}*"
    ]
  }

  dynamic "statement" {
    for_each = each.value.invalidate ? [1] : []

    content {
      sid       = "ClearCdnCache"
      actions   = ["cloudfront:CreateInvalidation"]
      resources = [aws_cloudfront_distribution.share.arn]
    }
  }
}

resource "aws_iam_user_policy" "uploader" {
  for_each = local.uploaders

  name   = "${local.bucket_name}-${each.key}-write"
  user   = aws_iam_user.uploader[each.key].name
  policy = data.aws_iam_policy_document.uploader[each.key].json
}
