# terraform-modules

[![ci](https://github.com/tomaseduar60/terraform-modules/actions/workflows/ci.yml/badge.svg)](https://github.com/tomaseduar60/terraform-modules/actions/workflows/ci.yml)
![Terraform](https://img.shields.io/badge/Terraform-%E2%89%A51.5-7B42BC?logo=terraform&logoColor=white)
![Google Cloud](https://img.shields.io/badge/Google_Cloud-4285F4?logo=googlecloud&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-0078D4?logo=microsoftazure&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white)
![Crossplane](https://img.shields.io/badge/Crossplane-EF7B4D?logo=crossplane&logoColor=white)
![Kafka](https://img.shields.io/badge/Kafka-231F20?logo=apachekafka&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green)

Módulos de Terraform reutilizables para levantar plataforma en **GCP** y **Azure**: clusters de Kubernetes, servicios serverless, secretos con External Secrets y topics de Kafka con Crossplane.

Los armé a partir de los patrones que más repito en el día a día: clusters privados con Workload Identity, cero credenciales estáticas, secretos que nunca pasan por el state y node pools spot para bajar costos. Todo con valores por defecto pensados para producción y ejemplos listos para `terraform plan`.

## Módulos

| Módulo | Nube | Qué crea |
|---|---|---|
| [`gcp/gke`](modules/gcp/gke) | GCP | Cluster GKE privado, Workload Identity, release channel, node pools con autoscaling y spot |
| [`gcp/cloud-run`](modules/gcp/cloud-run) | GCP | Servicio Cloud Run v2 con service account dedicada, secretos como env vars y probes |
| [`gcp/secret-manager`](modules/gcp/secret-manager) | GCP | Secretos sin valor en el state, replicación configurable y permisos de lectura por secreto |
| [`azure/aks`](modules/azure/aks) | Azure | AKS con OIDC + Workload Identity, Azure CNI Overlay con Cilium, RBAC de Entra ID y node pools spot |
| [`k8s/external-secret-gsm`](modules/k8s/external-secret-gsm) | GCP + K8s | Secretos en Secret Manager + permisos para ESO + `ExternalSecret` con todas las keys de la app |
| [`k8s/kafka-topic-crossplane`](modules/k8s/kafka-topic-crossplane) | K8s | Topic de Kafka (Confluent Cloud) como claim de Crossplane, con XRD y Composition incluidos |

## Estructura

```
.
├── modules/
│   ├── gcp/
│   │   ├── gke/
│   │   ├── cloud-run/
│   │   └── secret-manager/
│   ├── azure/
│   │   └── aks/
│   └── k8s/
│       ├── external-secret-gsm/
│       └── kafka-topic-crossplane/   # + XRD y Composition
├── examples/
│   ├── gcp-platform/   # GKE + secretos + API en Cloud Run
│   ├── azure-aks/      # AKS con node pool spot
│   └── k8s-app/        # secretos + topics de un microservicio
├── .github/workflows/ci.yml
├── .tflint.hcl
├── .pre-commit-config.yaml
└── Makefile
```

## Uso rápido

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

  node_pools = {
    general = { machine_type = "e2-standard-4", min_count = 2, max_count = 6 }
  }
}
```

Ejemplos completos en [`examples/`](examples).

## Decisiones de diseño

- **Sin credenciales estáticas.** GKE y AKS salen con Workload Identity activado; en AKS además se desactivan las cuentas locales y el acceso va por Entra ID.
- **Los secretos no viven en Terraform.** `secret-manager` crea el secreto y sus permisos, pero el valor se carga fuera (pipeline o `gcloud`), así nunca termina en el state.
- **Mínimo privilegio.** Cada servicio de Cloud Run corre con su propia service account y solo puede leer los secretos que usa.
- **Plataforma como API.** Los topics de Kafka se piden con un claim de Crossplane en el namespace del equipo; las credenciales del cluster de Kafka quedan del lado de la plataforma.
- **Un Secret por app.** `external-secret-gsm` junta todas las keys de una app en un solo Secret y devuelve los `secretKeyRef` listos para el Deployment.
- **Costos.** Node pools spot con taints para que solo entren las cargas que los toleran, y Cloud Run escalando a cero por defecto.
- **Protección contra borrados.** `deletion_protection` activado por defecto en GKE y Cloud Run.
- **Versionado.** Providers acotados por versión mayor y módulos consumibles por tag (`?ref=vX.Y.Z`).

## Desarrollo local

```bash
make fmt        # terraform fmt -recursive
make validate   # init -backend=false + validate en cada módulo y ejemplo
make lint       # tflint con los rulesets de Google y AzureRM
make check      # todo lo anterior
```

Con [pre-commit](https://pre-commit.com) instalado, `pre-commit install` corre fmt, validate y tflint antes de cada commit.

## CI

Cada PR y cada push a `main` corre en GitHub Actions:

1. `terraform fmt -check`
2. `terraform init -backend=false` + `terraform validate`, en paralelo por módulo y ejemplo
3. `tflint` con los rulesets de Google y AzureRM
4. `yamllint` sobre los manifiestos de Crossplane
5. `checkov` para revisar configuraciones de seguridad

## Licencia

[MIT](LICENSE)
