# k8s/external-secret-gsm

Resuelve los secretos de una aplicación de punta a punta con [External Secrets Operator](https://external-secrets.io) y GCP Secret Manager:

1. Crea en Secret Manager un secreto por cada key (`<gsm_prefix>-<key>`), sin valor.
2. Le da `secretAccessor` solo sobre esos secretos a la service account de ESO.
3. Crea un `ExternalSecret` que arma **un único Secret de Kubernetes** con todas las keys.

El output `env_from_secret` devuelve los bloques `env` con `secretKeyRef` listos para el Deployment, así el manifiesto y los secretos no se desincronizan.

```
Secret Manager                      Kubernetes (namespace payments)
payments-api-db-password      ─┐
payments-api-kafka-api-key    ─┼─>  ExternalSecret ──> Secret payments-api ──> Deployment
payments-api-kafka-api-secret ─┘                         DB_PASSWORD           env[].secretKeyRef
                                                         KAFKA_API_KEY
                                                         KAFKA_API_SECRET
```

Requisitos: ESO instalado y un `ClusterSecretStore` hacia Secret Manager autenticado con Workload Identity.

## Uso

```hcl
module "secrets" {
  source = "github.com/tomaseduar60/terraform-modules//modules/k8s/external-secret-gsm?ref=v1.0.0"

  name                = "payments-api"
  namespace           = "payments"
  project_id          = "my-project"
  gsm_prefix          = "payments-api"
  eso_service_account = "external-secrets@my-project.iam.gserviceaccount.com"
  keys                = ["DB_PASSWORD", "KAFKA_API_KEY", "KAFKA_API_SECRET"]
}
```

## Entradas

| Nombre | Descripción | Tipo | Default | Requerida |
|---|---|---|---|:---:|
| `name` | Nombre del ExternalSecret (y del Secret de Kubernetes si no se indica target_secret_name). | `string` | - | sí |
| `namespace` | Namespace de la aplicación. | `string` | - | sí |
| `keys` | Keys del Secret de Kubernetes, en formato de variable de entorno (ej. DB_PASSWORD). | `list(string)` | - | sí |
| `project_id` | Proyecto GCP donde viven los secretos. | `string` | - | sí |
| `gsm_prefix` | Prefijo de los secretos en Secret Manager, normalmente el nombre de la app. | `string` | - | sí |
| `create_gsm_secrets` | Si es false, solo crea el ExternalSecret (los secretos ya existen en Secret Manager). | `bool` | `true` | no |
| `eso_service_account` | Email de la GSA que usa External Secrets Operator vía Workload Identity. | `string` | - | sí |
| `secret_store_name` | Nombre del SecretStore o ClusterSecretStore apuntando a Secret Manager. | `string` | `"gcp-secret-manager"` | no |
| `secret_store_kind` | SecretStore o ClusterSecretStore. | `string` | `"ClusterSecretStore"` | no |
| `target_secret_name` | Nombre del Secret de Kubernetes resultante. Por defecto, igual a name. | `string` | `null` | no |
| `refresh_interval` | Cada cuánto ESO vuelve a leer Secret Manager. | `string` | `"1h"` | no |
| `eso_api_version` | apiVersion de ExternalSecret según la versión de ESO instalada. | `string` | `"external-secrets.io/v1"` | no |
| `labels` | Labels para los secretos y el ExternalSecret. | `map(string)` | `{}` | no |

## Salidas

| Nombre | Descripción |
|---|---|
| `secret_name` | Nombre del Secret de Kubernetes que crea ESO. |
| `gsm_secret_names` | Secretos de Secret Manager por key. Hay que cargarles el valor fuera de Terraform. |
| `env_from_secret` | Bloques env listos para el Deployment (una entrada secretKeyRef por key). |
