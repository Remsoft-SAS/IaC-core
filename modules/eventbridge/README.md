# EventBridge Custom Bus Module

Modulo Terraform para crear un EventBridge custom bus con soporte opcional
para reutilizar un bus existente en lugar de crear uno nuevo.

## Uso

### Crear un bus nuevo (default)

```hcl
module "event_bus" {
  source      = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/eventbridge?ref=main"
  bus_name    = "rempays-messaging"
  environment = var.environment
  tags        = { Project = "rempays" }
}
```

Crea: `rempays-messaging-{environment}`

### Reutilizar un bus existente

```hcl
module "event_bus" {
  source           = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/eventbridge?ref=main"
  bus_name         = "cualquier-nombre"   # ignorado cuando create = false
  environment      = var.environment
  create           = false
  existing_bus_arn = "arn:aws:events:us-east-1:123456789012:event-bus/mi-bus"
}
```

Los outputs `bus_name` y `bus_arn` funcionan igual en ambos casos.

## Inputs

| Variable | Descripcion | Tipo | Default | Requerido |
|----------|-------------|------|---------|-----------|
| `bus_name` | Nombre base del bus (se agrega `-{environment}`) | `string` | - | Si |
| `environment` | Entorno de despliegue (develop / production) | `string` | - | Si |
| `create` | Si es `false`, no crea el bus y usa `existing_bus_arn` | `bool` | `true` | No |
| `existing_bus_arn` | ARN de un bus existente (solo si `create = false`) | `string` | `""` | No |
| `tags` | Tags adicionales | `map(string)` | `{}` | No |

## Outputs

| Output | Descripcion |
|--------|-------------|
| `bus_name` | Nombre del bus (creado o existente) |
| `bus_arn` | ARN del bus (creado o existente) |

## Agregar reglas desde modulos downstream

El bus solo define el canal. Cada modulo consumer agrega sus propias reglas:

```hcl
resource "aws_cloudwatch_event_rule" "on_message_received" {
  name           = "on-message-received-${var.environment}"
  event_bus_name = module.event_bus.bus_name   # output de este modulo

  event_pattern = jsonencode({
    source      = ["rempays.messaging"]
    detail-type = ["message.received"]
  })
}

resource "aws_cloudwatch_event_target" "accumulator" {
  rule           = aws_cloudwatch_event_rule.on_message_received.name
  event_bus_name = module.event_bus.bus_name
  arn            = module.fn_accumulator.function_arn
}
```

---
*Created by Remsoft SAS - Infrastructure as Code Standard.*
