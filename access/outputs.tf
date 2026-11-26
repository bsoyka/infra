output "ben_emails" {
  description = "Addresses in the Ben group, from the PGP key."
  value       = local.ben_emails
}

output "upload_aud" {
  description = "Access audience tag for upload.bensoyka.net. Goes in share-upload's wrangler.toml (ACCESS_AUD)."
  value       = cloudflare_zero_trust_access_application.upload.aud
}
