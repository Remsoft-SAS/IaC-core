# modules/sns/main.tf

locals {
  full_name = var.fifo_topic ? "${var.topic_name}-${var.environment}.fifo" : "${var.topic_name}-${var.environment}"
}

# 1. SNS Topic
resource "aws_sns_topic" "this" {
  name                        = local.full_name
  display_name                = var.display_name
  fifo_topic                  = var.fifo_topic
  content_based_deduplication = var.content_based_deduplication
  kms_master_key_id           = var.kms_master_key_id

  tags = merge(
    {
      Name        = local.full_name
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

# 2. Topic Policy (Dynamic based on allowed_publishers)
resource "aws_sns_topic_policy" "this" {
  count = length(var.allowed_publishers) > 0 ? 1 : 0
  arn   = aws_sns_topic.this.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPublishers"
        Effect = "Allow"
        Principal = merge(
          length([for p in var.allowed_publishers : p if length(split(":", p)) > 1 || can(regex("^[0-9]{12}$", p))]) > 0 ? {
            AWS = [for p in var.allowed_publishers : p if length(split(":", p)) > 1 || can(regex("^[0-9]{12}$", p))]
          } : {},
          length([for p in var.allowed_publishers : p if length(split(":", p)) == 1 && !can(regex("^[0-9]{12}$", p))]) > 0 ? {
            Service = [for p in var.allowed_publishers : p if length(split(":", p)) == 1 && !can(regex("^[0-9]{12}$", p))]
          } : {}
        )
        Action   = "sns:Publish"
        Resource = aws_sns_topic.this.arn
      }
    ]
  })
}
