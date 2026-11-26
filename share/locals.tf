locals {
  domain      = "share.bensoyka.com"
  bucket_name = "bsoyka-share"

  # Where files live. Each prefix has its own retention and its own CloudFront
  # behavior (cdn.tf):
  #   inline   - rendered in the browser, under a CSP sandbox
  #   download - always downloaded (Content-Disposition: attachment)
  prefixes = {
    screenshot = { path = "screenshot/", expire_days = 90, render = "inline" }
    file       = { path = "file/", expire_days = 60, render = "download" }
  }

  # One IAM user per uploading client, write-only to the prefixes listed.
  # `delete` adds s3:DeleteObject on those prefixes; `invalidate` lets it clear
  # CloudFront's cache (so a deleted file stops downloading right away instead
  # of up to a day later).
  uploaders = {
    # Shottr screenshots. Never needs to delete.
    shottr = { prefixes = ["screenshot"], delete = false, invalidate = false }

    # Thunderbird FileLink: deletes an upload when the attachment is removed
    # from a draft.
    mail = { prefixes = ["file"], delete = true, invalidate = false }

    # The share-upload Worker (upload.bensoyka.net and the `share` CLI): signs
    # short-lived upload URLs and can undo an upload.
    upload = { prefixes = ["file"], delete = true, invalidate = true }
  }

  # Origins allowed to PUT straight to the bucket from a browser (presigned
  # URLs handed out by the share-upload Worker).
  upload_origins = ["https://upload.bensoyka.net"]
}
