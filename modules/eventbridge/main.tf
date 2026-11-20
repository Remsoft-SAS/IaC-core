# modules/eventbridge/main.tf

resource "aws_cloudwatch_event_bus" "this" {
  count = var.create ? 1 : 0

  name = "${var.bus_name}-${var.environment}"
  tags = var.tags
}

locals {
  bus_name = var.create ? aws_cloudwatch_event_bus.this[0].name : var.existing_bus_name
}

resource "aws_cloudwatch_event_rule" "this" {
  for_each = var.rules

  name                = "${each.key}-${var.environment}"
  description         = each.value.description
  event_bus_name      = local.bus_name
  event_pattern       = each.value.event_pattern
  schedule_expression = each.value.schedule_expression
  state               = each.value.enabled ? "ENABLED" : "DISABLED"
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "this" {
  for_each = {
    for item in flatten([
      for rule_name, rule in var.rules : [
        for target_id, target in rule.targets : {
          key       = "${rule_name}/${target_id}"
          rule_name = rule_name
          target_id = target_id
          target    = target
        }
      ]
    ]) : item.key => item
  }

  rule           = aws_cloudwatch_event_rule.this[each.value.rule_name].name
  event_bus_name = local.bus_name
  target_id      = each.value.target_id
  arn            = each.value.target.arn
  role_arn       = each.value.target.role_arn
  input          = each.value.target.input
}

resource "aws_scheduler_schedule" "this" {
  for_each = var.schedules

  name                         = "${each.key}-${var.environment}"
  description                  = each.value.description
  schedule_expression          = each.value.schedule_expression
  schedule_expression_timezone = each.value.schedule_expression_timezone
  state                        = each.value.state
  start_date                   = each.value.start_date
  end_date                     = each.value.end_date
  group_name                   = each.value.group_name

  flexible_time_window {
    mode = each.value.flexible_time_window_mode
    maximum_window_in_minutes = each.value.flexible_time_window_mode == "FLEXIBLE" ? each.value.flexible_time_window_minutes : null
  }

  target {
    arn      = each.value.target_arn
    role_arn = each.value.target_role_arn
    input    = each.value.target_input

    dynamic "retry_policy" {
      for_each = each.value.retry_maximum_attempts != null || each.value.retry_maximum_event_age != null ? [1] : []
      content {
        maximum_event_age_in_seconds = each.value.retry_maximum_event_age
        maximum_retry_attempts      = each.value.retry_maximum_attempts
      }
    }

    dynamic "dead_letter_config" {
      for_each = each.value.dead_letter_arn != null ? [1] : []
      content {
        arn = each.value.dead_letter_arn
      }
    }
  }

  lifecycle {
    precondition {
      condition     = each.value.flexible_time_window_mode != "FLEXIBLE" || each.value.flexible_time_window_minutes != null
      error_message = "Set flexible_time_window_minutes when flexible_time_window_mode is FLEXIBLE."
    }
  }
}
