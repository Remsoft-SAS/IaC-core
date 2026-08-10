# module: step_functions

Crea una AWS Step Functions State Machine con su IAM role de ejecucion, CloudWatch Log Group, y opcionalmente un trigger desde EventBridge.

## Uso

```hcl
module "cortex_sfn" {
  source      = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/step_functions?ref=main"
  name        = "rempays-cortex"
  environment = "develop"
  type        = "EXPRESS"

  definition = file("${path.module}/definition.asl.json")

  lambda_arns = [
    module.fn_cortex.function_arn,
    module.fn_db_writer.function_arn,
    module.fn_whatsapp_sender.function_arn,
    module.fn_session_updater.function_arn,
  ]

  eventbridge_trigger = {
    bus_name      = "rempays-messaging-develop"
    event_pattern = jsonencode({
      detail-type = ["message.received"]
    })
  }

  tags = {
    Project     = "rempays"
    Environment = "develop"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Variable | Tipo | Default | Descripcion |
|----------|------|---------|-------------|
| `name` | `string` | — | Nombre base. Resultado: `{name}-{environment}` |
| `environment` | `string` | — | Entorno de despliegue (`develop` / `production`) |
| `definition` | `string` | — | Definicion ASL de la State Machine (JSON string) |
| `type` | `string` | `"EXPRESS"` | Tipo: `STANDARD` o `EXPRESS` |
| `lambda_arns` | `list(string)` | `[]` | ARNs de Lambdas que la State Machine puede invocar |
| `log_level` | `string` | `"ERROR"` | Nivel de log: `ALL` \| `ERROR` \| `FATAL` \| `OFF` |
| `log_include_execution_data` | `bool` | `false` | Incluir input/output de cada estado en los logs |
| `log_retention_days` | `number` | `14` | Dias de retencion del Log Group |
| `eventbridge_trigger` | `object` | `null` | Trigger EventBridge. `null` = sin trigger automatico |
| `tags` | `map(string)` | `{}` | Tags comunes para todos los recursos |

### eventbridge_trigger

```hcl
eventbridge_trigger = {
  bus_name      = string  # Nombre del EventBridge bus
  event_pattern = string  # JSON string del patron de eventos
}
```

## Outputs

| Output | Descripcion |
|--------|-------------|
| `state_machine_arn` | ARN de la State Machine |
| `state_machine_name` | Nombre de la State Machine |
| `role_arn` | ARN del IAM role de ejecucion |

## Recursos creados

| Recurso | Nombre |
|---------|--------|
| `aws_sfn_state_machine` | `{name}-{environment}` |
| `aws_iam_role` | `{name}-{environment}-role` |
| `aws_iam_role_policy` (lambdas) | `InvokeLambdas` |
| `aws_iam_role_policy` (logs) | `CloudWatchLogs` |
| `aws_cloudwatch_log_group` | `/aws/states/{name}-{environment}` |
| `aws_cloudwatch_event_rule` *(opcional)* | `{name}-{environment}-trigger` |
| `aws_iam_role` *(opcional)* | `{name}-{environment}-eb-role` |
| `aws_cloudwatch_event_target` *(opcional)* | — |

## Notas

- **EXPRESS vs STANDARD:** EXPRESS es ideal para pipelines de alta frecuencia (duracion < 5 min, cobro por ejecucion/duracion). STANDARD para flujos de larga duracion con historial completo.
- **`log_level = "ALL"`** en desarrollo facilita el debugging desde la consola de AWS Step Functions.
- El trigger EventBridge crea un IAM role separado (`-eb-role`) que solo tiene permiso `states:StartExecution` sobre esta State Machine.
