# One IAM user per uploading client, each limited to writing under its own
# prefix. Access keys are deliberately NOT managed here (they'd land in state
# in plaintext); create them with the CLI and store them in 1Password. See
# README.

resource "aws_iam_user" "uploader" {
  for_each = local.prefixes

  name = "${local.bucket_name}-${each.key}"
  path = "/share/"
}

data "aws_iam_policy_document" "uploader" {
  for_each = local.prefixes

  statement {
    sid = "WriteOwnPrefix"
    actions = concat(
      ["s3:PutObject", "s3:AbortMultipartUpload"],
      # Thunderbird's FileLink can delete an upload when the attachment is
      # removed from a draft; Shottr never needs to delete.
      each.key == "mail" ? ["s3:DeleteObject"] : [],
    )
    resources = ["${aws_s3_bucket.share.arn}/${each.value.path}*"]
  }
}

resource "aws_iam_user_policy" "uploader" {
  for_each = local.prefixes

  name   = "${local.bucket_name}-${each.key}-write"
  user   = aws_iam_user.uploader[each.key].name
  policy = data.aws_iam_policy_document.uploader[each.key].json
}
