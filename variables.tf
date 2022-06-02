variable "aws_region" {
  type        = string
  description = "The AWS region to put the bucket into"
  default     = "us-east-1"
}

variable "site_domain" {
  type        = string
  description = "The domain name to use for the static site"
}

variable "staging_domain" {
  type        = string
  description = "The staging domain name to use for the staging site"
}

variable "argo_subdomain" {
  type        = string
  description = "The subdomain name to use for the argo tunnel site"
}

variable "cloudflare_account_id" {
  type        = string
  description = "The account_id to use for the argo tunnel site"
}

variable "GITHUB_ID" {
  type        = string
  description = "The GITHUB_ID to use for the GitHub AUTH"
}

variable "GITHUB_SECRET" {
  type        = string
  description = "The account_id to use for the GitHub AUTH"
}
