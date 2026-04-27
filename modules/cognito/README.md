# 🔐 Módulo Cognito: User Pool & Client (Elite Edition)

Módulo ultra-inteligente para gestionar la autenticación en AWS. Se encarga de todo el "trabajo sucio" de DNS, certificados y permisos.

## 🚀 Características "Smart"
- **Auto-Discovery DNS/ACM:** Si pasas `domain_name`, el módulo encuentra solo la Zona de Route53 y el Certificado Wildcard.
- **Gestión de Dominio Custom:** Crea automáticamente el subdominio de Cognito y el registro DNS Alias.
- **Permisos de Lambda Automáticos:** Configura los `aws_lambda_permission` para cada trigger sin intervención manual.
- **Social Login Built-in:** Soporte nativo para Google y Microsoft OIDC.

## 📋 Uso "Elite" (Mínimo Código)
Con solo pasar el dominio y los triggers, el módulo se encarga del resto:

```hcl
module "cognito" {
  source        = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/cognito?ref=main"
  pool_name     = "rempays"
  environment   = "production"
  
  # Automatización DNS
  domain_name   = "rempays.com"
  custom_domain = "auth.rempays.com"

  # Triggers (Los permisos se crean solos)
  lambda_create_auth_arn = "arn:aws:lambda:..."
  
  # OAuth
  callback_urls = ["https://app.rempays.com/callback"]
}
```

## ⚙️ Variables destacadas
| Nombre | Descripción | Default |
| :--- | :--- | :--- |
| `domain_name` | Dominio base para descubrimiento (ej: `rempays.online`) | `""` |
| `custom_domain` | Subdominio completo para Cognito (ej: `auth.rempays.online`) | `""` |
| `lambda_xxx_arn` | ARNs de triggers (Define, Create, Verify, Pre-Signup) | `null` |
| `google_client_id` | ID para login con Google | `""` |

---
*Este módulo está diseñado para ser 100% autónomo y agnóstico al ambiente.*
