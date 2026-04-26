# modules/dynamodb/main.tf
# Generic module for DynamoDB tables

locals {
  table_name = "${var.table_name}-${var.environment}"
}

resource "aws_dynamodb_table" "this" {
  name           = local.table_name
  billing_mode   = var.billing_mode
  hash_key       = var.hash_key
  range_key      = var.range_key
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  # Only declare attributes used in keys or indexes
  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  # Global Secondary Indexes
  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      range_key          = try(global_secondary_index.value.range_key, null)
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = global_secondary_index.value.projection_type == "INCLUDE" ? try(global_secondary_index.value.non_key_attributes, null) : null
      read_capacity      = var.billing_mode == "PROVISIONED" ? try(global_secondary_index.value.read_capacity, 5) : null
      write_capacity     = var.billing_mode == "PROVISIONED" ? try(global_secondary_index.value.write_capacity, 5) : null
    }
  }

  # Local Secondary Indexes
  dynamic "local_secondary_index" {
    for_each = var.local_secondary_indexes
    content {
      name               = local_secondary_index.value.name
      range_key          = local_secondary_index.value.range_key
      projection_type    = local_secondary_index.value.projection_type
      non_key_attributes = local_secondary_index.value.projection_type == "INCLUDE" ? try(local_secondary_index.value.non_key_attributes, null) : null
    }
  }

  # TTL
  dynamic "ttl" {
    for_each = var.ttl_attribute != null ? [1] : []
    content {
      enabled        = true
      attribute_name = var.ttl_attribute
    }
  }

  # Point-in-time recovery — always enabled in production
  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  # Server-side encryption
  server_side_encryption {
    enabled     = var.enable_encryption
    kms_key_arn = var.kms_key_arn
  }

  # Streams for event-driven architectures (WebSockets, triggers, etc.)
  stream_enabled   = var.enable_streams
  stream_view_type = var.enable_streams ? var.stream_view_type : null

  # Global table (multi-region)
  dynamic "replica" {
    for_each = var.replica_regions
    content {
      region_name = replica.value
    }
  }

  tags = merge(
    {
      Name        = local.table_name
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )
}
