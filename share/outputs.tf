output "bucket" {
  value = aws_s3_bucket.share.bucket
}

output "cloudfront_domain" {
  description = "CNAME target for share.bensoyka.com (dns/zones-bensoyka-com.tf)."
  value       = aws_cloudfront_distribution.share.domain_name
}

output "acm_validation_records" {
  description = "CNAME(s) to add in dns/zones-bensoyka-com.tf so ACM can issue the certificate."
  value = {
    for o in aws_acm_certificate.share.domain_validation_options : o.domain_name => {
      name  = o.resource_record_name
      type  = o.resource_record_type
      value = o.resource_record_value
    }
  }
}

output "uploader_users" {
  value = { for k, u in aws_iam_user.uploader : k => u.name }
}
