# modules/eventbridge/main.tf

resource "aws_cloudwatch_event_bus" "this" {
  count = var.create ? 1 : 0

  name = "${var.bus_name}-${var.environment}"
  tags = var.tags
}
