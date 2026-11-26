# share.bensoyka.com: CloudFront in front of the private bucket.

resource "aws_acm_certificate" "share" {
  domain_name       = local.domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Waits until the validation CNAME (added by hand in dns/zones-bensoyka-com.tf,
# see README) resolves and ACM issues the certificate.
resource "aws_acm_certificate_validation" "share" {
  certificate_arn = aws_acm_certificate.share.arn
}

resource "aws_cloudfront_origin_access_control" "share" {
  name                              = local.bucket_name
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

# Uploaded files are content I didn't author for this domain, so nothing
# served here should be able to run script as share.bensoyka.com.
#
# - inline prefixes (screenshot/): rendered inline, under a CSP sandbox.
# - download prefixes (file/): forced to download. A sandbox CSP
#   would also stop browsers' built-in PDF viewers, and most shared files are
#   PDFs, so instead these never render on this origin at all.
#
# Both get nosniff, no-referrer, HSTS, and a noindex header.
locals {
  response_policies = {
    inline = {
      csp     = "sandbox"
      headers = tomap({})
    }
    download = {
      csp     = null
      headers = tomap({ "Content-Disposition" = "attachment" })
    }
  }
}

resource "aws_cloudfront_response_headers_policy" "share" {
  for_each = local.response_policies

  name = "${local.bucket_name}-${each.key}"

  security_headers_config {
    content_type_options {
      override = true
    }

    dynamic "content_security_policy" {
      for_each = each.value.csp == null ? [] : [each.value.csp]

      content {
        content_security_policy = content_security_policy.value
        override                = true
      }
    }

    referrer_policy {
      referrer_policy = "no-referrer"
      override        = true
    }

    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = false
      override                   = true
    }
  }

  custom_headers_config {
    items {
      header   = "X-Robots-Tag"
      value    = "noindex, nofollow"
      override = true
    }

    dynamic "items" {
      for_each = each.value.headers

      content {
        header   = items.key
        value    = items.value
        override = true
      }
    }
  }
}

resource "aws_cloudfront_distribution" "share" {
  enabled         = true
  comment         = local.domain
  aliases         = [local.domain]
  is_ipv6_enabled = true
  http_version    = "http2and3"
  price_class     = "PriceClass_100"

  # No default_root_object: the bare domain should just 403, not list or
  # serve anything.

  origin {
    origin_id                = "s3-share"
    domain_name              = aws_s3_bucket.share.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.share.id
  }

  default_cache_behavior {
    target_origin_id           = "s3-share"
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["GET", "HEAD"]
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.share["inline"].id
  }

  # Every download prefix gets the download policy; anything else (inline
  # prefixes) falls through to the default behavior above.
  dynamic "ordered_cache_behavior" {
    for_each = { for k, p in local.prefixes : k => p if p.render == "download" }

    content {
      path_pattern               = "${ordered_cache_behavior.value.path}*"
      target_origin_id           = "s3-share"
      viewer_protocol_policy     = "redirect-to-https"
      allowed_methods            = ["GET", "HEAD"]
      cached_methods             = ["GET", "HEAD"]
      compress                   = true
      cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.share["download"].id
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.share.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
