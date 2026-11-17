resource "aws_wafv2_web_acl" "this" {
  name        = var.name
  description = var.description
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = var.rule_name
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit                 = var.rate_limit_per_5m
        evaluation_window_sec = var.evaluation_window_sec
        aggregate_key_type    = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = var.metric_name != null ? var.metric_name : "${var.name}-rate-limit"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = var.name
    sampled_requests_enabled   = false
  }

  tags = var.tags
}

resource "aws_wafv2_web_acl_association" "this" {
  count = length(var.resource_arns)

  resource_arn = var.resource_arns[count.index]
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}
