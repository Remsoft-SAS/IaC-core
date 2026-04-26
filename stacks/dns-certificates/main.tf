# stacks/dns-certificates/main.tf
# Stack for managing global DNS zones and SSL certificates

# 1. Route 53 Zone
module "route53" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/route53?ref=main"

  domain_name = var.domain_name
  environment = var.environment
  create_zone = true
}

# 2. Wildcard SSL Certificate (*.domain.com)
# This certificate is vital for CloudFront and APIs
module "acm" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/acm?ref=main"

  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  environment               = var.environment
  zone_id                   = module.route53.zone_id
}
