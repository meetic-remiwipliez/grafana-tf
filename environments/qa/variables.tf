variable "grafana_url" {
  description = "URL de l'instance Grafana"
  type        = string
}

variable "grafana_auth_token" {
  description = "Token d'authentification Grafana"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Environnement (qa/prod)"
  type        = string
  default     = "qa"
}

variable "alert_rules" {
  description = "Configuration des règles d'alertes supplémentaires"
  type = map(object({
    name        = string
    description = string
    query       = string
    duration    = string
    datasource  = optional(string, "prometheus")
  }))
  default = {}
}

variable "notification_channels" {
  description = "Configuration des canaux de notification"
  type = map(object({
    name         = string
    type         = string
    email        = optional(list(string), [])
    send_resolved = optional(bool, true)
    webhook_url  = optional(string, "")
    channel      = optional(string, "")
    username     = optional(string, "Grafana")
    icon_emoji   = optional(string, ":exclamation:")
    title        = optional(string, "")
    text         = optional(string, "")
    http_method  = optional(string, "POST")
    max_alerts   = optional(number, 0)
    integration_key = optional(string, "")
    severity     = optional(string, "error")
    component    = optional(string, "Grafana")
    group        = optional(string, "")
    class        = optional(string, "")
  }))
  default = {}
}

variable "common_tags" {
  description = "Tags communs à toutes les ressources"
  type        = map(string)
  default = {
    Environment = "qa"
    ManagedBy   = "terraform"
  }
}



# Variables pour les règles d'alertes Kubernetes générées depuis YAML
variable "kubernetes_apps_rules" {
  description = "Règles d'alertes pour les applications Kubernetes"
  type = list(object({
    name        = string
    expr        = string
    for         = string
    annotations = map(string)
    labels      = map(string)
  }))
  default = []
}

variable "kubernetes_resources_rules" {
  description = "Règles d'alertes pour les ressources Kubernetes"
  type = list(object({
    name        = string
    expr        = string
    for         = string
    annotations = map(string)
    labels      = map(string)
  }))
  default = []
}

variable "kubernetes_storage_rules" {
  description = "Règles d'alertes pour le stockage Kubernetes"
  type = list(object({
    name        = string
    expr        = string
    for         = string
    annotations = map(string)
    labels      = map(string)
  }))
  default = []
}

variable "kubernetes_system_rules" {
  description = "Règles d'alertes pour le système Kubernetes"
  type = list(object({
    name        = string
    expr        = string
    for         = string
    annotations = map(string)
    labels      = map(string)
  }))
  default = []
}

# Variables pour les règles d'enregistrement Kubernetes générées depuis YAML
variable "kube_apiserver_availability_rules" {
  description = "Règles d'enregistrement pour la disponibilité de l'API Server"
  type = list(object({
    record      = string
    expr        = string
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})
  }))
  default = []
}

variable "kube_apiserver_burnrate_rules" {
  description = "Règles d'enregistrement pour le burn rate de l'API Server"
  type = list(object({
    record      = string
    expr        = string
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})
  }))
  default = []
}

variable "kube_apiserver_histogram_rules" {
  description = "Règles d'enregistrement pour les histogrammes de l'API Server"
  type = list(object({
    record      = string
    expr        = string
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})
  }))
  default = []
}

variable "k8s_rules" {
  description = "Règles d'enregistrement générales Kubernetes"
  type = list(object({
    record      = string
    expr        = string
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})
  }))
  default = []
}

variable "kube_scheduler_rules" {
  description = "Règles d'enregistrement pour le scheduler Kubernetes"
  type = list(object({
    record      = string
    expr        = string
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})
  }))
  default = []
}

variable "node_rules" {
  description = "Règles d'enregistrement pour les nodes"
  type = list(object({
    record      = string
    expr        = string
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})
  }))
  default = []
}

variable "kubelet_rules" {
  description = "Règles d'enregistrement pour kubelet"
  type = list(object({
    record      = string
    expr        = string
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})
  }))
  default = []
}
