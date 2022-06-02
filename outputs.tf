# output "website_bucket_name" {
#   description = "Name (id) of the bucket"
#   value       = aws_s3_bucket.site.id
# }

# output "bucket_endpoint" {
#   description = "Bucket endpoint"
#   value       = aws_s3_bucket.site.website_endpoint
# }

# output "domain_name" {
#   description = "Website endpoint"
#   value       = var.site_domain
# }

# output "staging_domain" {
#   description = "staging_domain"
#   value       = var.staging_domain
# }

# output "zone_id" {
#   description = "zone_id"
#   value       = data.cloudflare_zones.domain.zones[0].id
# }

# output "account_id" {
#   description = "cloudflare_account_id"
#   value       = var.cloudflare_account_id
# }