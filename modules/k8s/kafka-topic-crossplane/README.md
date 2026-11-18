# k8s/kafka-topic-crossplane

Topics de Kafka como recurso de plataforma con [Crossplane](https://crossplane.io). Cada equipo pide su topic en su namespace con un claim `KafkaTopic`; la Composition lo crea en el cluster de Kafka (Confluent Cloud o cualquier Kafka) usando las credenciales de la plataforma. Los equipos nunca ven la API key del cluster.

En [`crossplane/`](crossplane) está la API completa:

| Archivo | Qué es |
|---|---|
| `xrd.yaml` | CompositeResourceDefinition: el contrato (`XKafkaTopic` / claim `KafkaTopic`) con validaciones |
| `composition.yaml` | Implementación con [provider-kafka](https://github.com/crossplane-contrib/provider-kafka) y function-patch-and-transform |
| `provider-config.yaml` | Conexión SASL_SSL a Confluent Cloud con credenciales desde un Secret |

El módulo espera a que el claim quede `Ready`, así un `terraform apply` falla si el topic no se pudo crear. El nombre por defecto es `<namespace>.<name>`, lo que deja claro de qué equipo es cada topic.

## Uso

```hcl
module "orders_created" {
  source = "github.com/tomaseduar60/terraform-modules//modules/k8s/kafka-topic-crossplane?ref=v1.0.0"

  name       = "orders-created"
  namespace  = "payments"
  partitions = 12

  extra_config = {
    "max.message.bytes" = "2097152"
  }
}
```

## Entradas

| Nombre | Descripción | Tipo | Default | Requerida |
|---|---|---|---|:---:|
| `name` | Nombre del claim en Kubernetes. | `string` | - | sí |
| `namespace` | Namespace del equipo dueño del topic. | `string` | - | sí |
| `topic_name` | Nombre real del topic en Kafka. Por defecto, <namespace>.<name>. | `string` | `null` | no |
| `partitions` | Cantidad de particiones (solo se puede aumentar). | `number` | `6` | no |
| `replication_factor` | Factor de replicación. Confluent Cloud exige 3. | `number` | `3` | no |
| `retention_ms` | Retención en milisegundos. -1 = infinita. | `number` | `604800000 # 7 días` | no |
| `cleanup_policy` | delete, compact o compact,delete. | `string` | `"delete"` | no |
| `extra_config` | Configuración adicional del topic (ej. max.message.bytes). | `map(string)` | `{}` | no |
| `composition_provider` | Label provider de la Composition a usar (ej. confluent). | `string` | `"confluent"` | no |
| `labels` | Labels del claim. | `map(string)` | `{}` | no |

## Salidas

| Nombre | Descripción |
|---|---|
| `topic_name` | Nombre del topic en Kafka. |
| `claim` | Referencia al claim de Crossplane. |
