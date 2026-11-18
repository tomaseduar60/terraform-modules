# gcp/secret-manager

Crea secretos en Secret Manager **sin valor**. Terraform maneja el secreto, la replicación y los permisos; el valor se carga aparte, así nunca queda guardado en el state:

```bash
printf '%s' "$VALOR" | gcloud secrets versions add api-db-password --data-file=-
```

La replicación es automática por defecto, o por las regiones que se indiquen en `replica_locations`.

## Uso

```hcl
module "secrets" {
  source = "github.com/tomaseduar60/terraform-modules//modules/gcp/secret-manager?ref=v1.0.0"

  project_id = "my-project"

  secrets = {
    "api-db-password" = {
      accessors = ["serviceAccount:run-api@my-project.iam.gserviceaccount.com"]
    }
    "payments-key" = {
      replica_locations = ["us-central1", "us-east1"]
    }
  }
}
```

## Entradas

| Nombre | Descripción | Tipo | Default | Requerida |
|---|---|---|---|:---:|
| `project_id` | ID del proyecto GCP. | `string` | - | sí |
| `secrets` | Secretos por nombre. accessors: miembros IAM con permiso de lectura (ej. serviceAccount:app@p.iam.gserviceaccount.com). | `map(object)` | - | sí |
| `labels` | Labels comunes a todos los secretos. | `map(string)` | `{}` | no |

## Salidas

| Nombre | Descripción |
|---|---|
| `secret_ids` | IDs completos de los secretos, por nombre. |
| `secret_names` | Nombres cortos de los secretos. |
