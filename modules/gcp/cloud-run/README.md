# gcp/cloud-run

Servicio Cloud Run v2. Si no se pasa una service account, crea una dedicada. Los secretos de Secret Manager se inyectan como variables de entorno, y el módulo le da a esa service account permiso de lectura solo sobre esos secretos.

Trae startup y liveness probes, CPU solo durante requests y escala a cero por defecto. El acceso público está apagado salvo que se active `allow_unauthenticated`.

## Uso

```hcl
module "api" {
  source = "github.com/tomaseduar60/terraform-modules//modules/gcp/cloud-run?ref=v1.0.0"

  name       = "api"
  project_id = "my-project"
  region     = "us-central1"
  image      = "us-docker.pkg.dev/my-project/apps/api@sha256:..."

  env = {
    LOG_LEVEL = "info"
  }

  secret_env = {
    DB_PASSWORD = { secret = "api-db-password" }
  }

  min_instances = 1
}
```

## Entradas

| Nombre | Descripción | Tipo | Default | Requerida |
|---|---|---|---|:---:|
| `name` | Nombre del servicio. | `string` | - | sí |
| `project_id` | ID del proyecto GCP. | `string` | - | sí |
| `region` | Región de Cloud Run. | `string` | - | sí |
| `image` | Imagen del contenedor (idealmente con digest). | `string` | - | sí |
| `port` | Puerto que expone el contenedor. | `number` | `8080` | no |
| `cpu` | Límite de CPU. | `string` | `"1"` | no |
| `memory` | Límite de memoria. | `string` | `"512Mi"` | no |
| `min_instances` | Instancias mínimas (0 = escala a cero). | `number` | `0` | no |
| `max_instances` | Instancias máximas. | `number` | `5` | no |
| `health_path` | Ruta HTTP para startup y liveness probes. | `string` | `"/healthz"` | no |
| `env` | Variables de entorno en texto plano (nada sensible). | `map(string)` | `{}` | no |
| `secret_env` | Variables de entorno desde Secret Manager: NOMBRE => { secret, version }. | `map(object)` | `{}` | no |
| `service_account_email` | Service account existente. Si es null, se crea una dedicada. | `string` | `null` | no |
| `ingress` | INGRESS_TRAFFIC_ALL, INGRESS_TRAFFIC_INTERNAL_ONLY o INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER. | `string` | `"INGRESS_TRAFFIC_ALL"` | no |
| `allow_unauthenticated` | Si es true, cualquiera puede invocar el servicio. | `bool` | `false` | no |
| `deletion_protection` | Evita que terraform destroy borre el servicio. | `bool` | `true` | no |
| `labels` | Labels del servicio. | `map(string)` | `{}` | no |

## Salidas

| Nombre | Descripción |
|---|---|
| `uri` | URL del servicio. |
| `service_account_email` | Service account con la que corre el servicio. |
| `latest_revision` | Última revisión creada. |
