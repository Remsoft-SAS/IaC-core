# 🔐 Módulo Cognito: User Pool & Client

Módulo inteligente para gestionar la autenticación en AWS Cognito, con soporte nativo para Custom Auth Flows (OTP/Magic Link) y Login Social (Google, Microsoft).

## 🚀 Características
- **Custom Auth Ready:** Soporte para triggers de Lambdas para flujos personalizados.
- **Social Login Built-in:** Creación automática de Identity Providers para Google y Microsoft OIDC.
- **Auto-Config Client:** El cliente de Cognito detecta automáticamente qué proveedores están activos.
- **Security First:** Protección de borrado en producción y políticas de contraseñas robustas.

## 📋 Uso Básico (Nativo AWS)
Si solo quieres usar el flujo nativo de email/password de Cognito, solo necesitas esto:

```hcl
module "cognito" {
  source      = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/cognito?ref=main"
  pool_name   = "mi-app"
  environment = "production"
}
```

## 🛡️ Uso Elite (Custom Auth + Social)
Para habilitar OTP por WhatsApp y Login Social:

```hcl
module "cognito" {
  source      = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/cognito?ref=main"
  pool_name   = "mi-app"
  environment = "production"

  # Triggers para OTP
  lambda_create_auth_arn = "arn:..."
  
  # Login Social (Opcional)
  google_client_id     = "..."
  google_client_secret = "..."
  
  microsoft_client_id     = "..."
  microsoft_client_secret = "..."
}
```

## ⚙️ Variables principales
| Nombre | Descripción | Tipo | Default |
| :--- | :--- | :--- | :--- |
| `pool_name` | Nombre base del User Pool | `string` | **Requerido** |
| `environment` | Ambiente (develop/production) | `string` | **Requerido** |
| `username_attributes` | Atributos de login (email, phone_number) | `list` | `["phone_number"]` |
| `google_client_id` | ID de cliente de Google para Social Auth | `string` | `""` |
| `microsoft_client_id` | ID de cliente de Microsoft para Social Auth | `string` | `""` |
| `lambda_define_auth_arn` | ARN de Lambda para definir el challenge | `string` | `null` |

---
*Nota: Los proveedores sociales solo se crean si se proporciona el Client ID correspondiente.*
