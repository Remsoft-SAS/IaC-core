# modules/sqs/main.tf
# Generic module for SQS queues with FIFO, Dead Letter Queue, and SNS Integration

locals {
  suffix     = var.fifo_queue ? ".fifo" : ""
  queue_name = "${var.queue_name}-${var.environment}${local.suffix}"
  dlq_name   = "${var.queue_name}-dlq-${var.environment}${local.suffix}"

  # Determine if we need to create a policy
  create_policy = var.queue_policy != null || var.sns_topic_arn != null
}

# ── Dead Letter Queue ──────────────────────────────────────────────────────────

resource "aws_sqs_queue" "dlq" {
  count = var.enable_dlq ? 1 : 0

  name                      = local.dlq_name
  message_retention_seconds = var.dlq_message_retention_seconds
  fifo_queue                = var.fifo_queue
  kms_master_key_id         = var.kms_key_id

  tags = merge(
    {
      Name        = local.dlq_name
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

# ── Main SQS Queue ─────────────────────────────────────────────────────────────

resource "aws_sqs_queue" "this" {
  name                       = local.queue_name
  delay_seconds              = var.delay_seconds
  max_message_size           = var.max_message_size
  message_retention_seconds  = var.message_retention_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds
  kms_master_key_id          = var.kms_key_id

  # FIFO
  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.fifo_queue ? var.content_based_deduplication : null
  deduplication_scope         = var.fifo_queue && var.high_throughput ? "messageGroup" : null
  fifo_throughput_limit       = var.fifo_queue && var.high_throughput ? "perMessageGroupId" : null

  # Dead Letter Queue
  redrive_policy = var.enable_dlq ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = var.max_receive_count
  }) : null

  tags = merge(
    {
      Name        = local.queue_name
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

# ── SNS Integration ───────────────────────────────────────────────────────────

resource "aws_sns_topic_subscription" "this" {
  count = var.sns_topic_arn != null ? 1 : 0

  topic_arn     = var.sns_topic_arn
  protocol      = "sqs"
  endpoint      = aws_sqs_queue.this.arn
  filter_policy = var.sns_filter_policy
}

# ── Queue Access Policy (Auto-managed) ─────────────────────────────────────────

data "aws_iam_policy_document" "combined" {
  count = local.create_policy ? 1 : 0

  # Base policy from user if provided
  source_policy_documents = var.queue_policy != null ? [var.queue_policy] : []

  # Automatic SNS Permission
  dynamic "statement" {
    for_each = var.sns_topic_arn != null ? [1] : []
    content {
      effect = "Allow"
      principals {
        type        = "Service"
        identifiers = ["sns.amazonaws.com"]
      }
      actions   = ["sqs:SendMessage"]
      resources = [aws_sqs_queue.this.arn]
      condition {
        test     = "ArnEquals"
        variable = "aws:SourceArn"
        values   = [var.sns_topic_arn]
      }
    }
  }
}

resource "aws_sqs_queue_policy" "this" {
  count = local.create_policy ? 1 : 0

  queue_url = aws_sqs_queue.this.url
  policy    = data.aws_iam_policy_document.combined[0].json
}
