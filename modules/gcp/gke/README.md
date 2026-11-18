# gcp/gke

Cluster GKE privado y regional. Nodos sin IP pública, Workload Identity, Shielded Nodes, release channel y ventana de mantenimiento. El node pool por defecto se elimina para que cada pool se maneje como recurso propio, con autoscaling, auto-repair y auto-upgrade.

Los nodos usan una service account que se pasa por variable: la idea es no usar nunca la default de Compute Engine.

## Uso

```hcl
module "gke" {
  source = "github.com/tomaseduar60/terraform-modules//modules/gcp/gke?ref=v1.0.0"

  name                 = "gke-prd"
  project_id           = "my-project"
  location             = "us-central1"
  network              = "vpc-main"
  subnetwork           = "snet-gke"
  pods_range_name      = "pods"
  services_range_name  = "services"
  node_service_account = "gke-nodes@my-project.iam.gserviceaccount.com"

  master_authorized_networks = [
    { cidr_block = "203.0.113.0/24", display_name = "vpn" },
  ]

  node_pools = {
    general = { machine_type = "e2-standard-4", min_count = 2, max_count = 6 }
    spot = {
      spot      = true
      max_count = 10
      taints    = [{ key = "spot", value = "true", effect = "NO_SCHEDULE" }]
    }
  }
}
```

## Entradas

| Nombre | Descripción | Tipo | Default | Requerida |
|---|---|---|---|:---:|
| `name` | Nombre del cluster. | `string` | - | sí |
| `project_id` | ID del proyecto GCP. | `string` | - | sí |
| `location` | Región (cluster regional) o zona (cluster zonal). | `string` | - | sí |
| `network` | Self link o nombre de la VPC. | `string` | - | sí |
| `subnetwork` | Self link o nombre de la subred. | `string` | - | sí |
| `pods_range_name` | Nombre del rango secundario de la subred para pods. | `string` | - | sí |
| `services_range_name` | Nombre del rango secundario de la subred para services. | `string` | - | sí |
| `master_ipv4_cidr_block` | CIDR /28 del control plane. | `string` | `"172.16.0.0/28"` | no |
| `private_endpoint` | Si es true, el control plane solo es accesible por IP privada. | `bool` | `false` | no |
| `master_authorized_networks` | Redes autorizadas para llegar al control plane. | `list(object)` | `[]` | no |
| `release_channel` | Canal de versiones de GKE: RAPID, REGULAR o STABLE. | `string` | `"REGULAR"` | no |
| `maintenance_window` | Ventana de mantenimiento recurrente (RFC 5545). | `object` | `ver variables.tf` | no |
| `node_service_account` | Email de la service account de los nodos (mínimos privilegios, no la default de Compute). | `string` | - | sí |
| `node_pools` | Node pools a crear, por nombre. | `map(object)` | `{ default = {} }` | no |
| `deletion_protection` | Evita que terraform destroy borre el cluster. | `bool` | `true` | no |
| `labels` | Labels para el cluster y los nodos. | `map(string)` | `{}` | no |

## Salidas

| Nombre | Descripción |
|---|---|
| `name` | Nombre del cluster. |
| `endpoint` | Endpoint del control plane. |
| `ca_certificate` | CA del cluster (base64). |
| `workload_identity_pool` | Pool de Workload Identity (<project>.svc.id.goog). |
| `node_pools` | Nombres de los node pools creados. |
