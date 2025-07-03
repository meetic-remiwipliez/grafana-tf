variable "datasource_uid" {
  description = "UID de la source de données Prometheus"
  type        = string
  default     = "prometheus"
}

variable "interval_seconds" {
  description = "Intervalle d'évaluation des règles en secondes"
  type        = number
  default     = 60
}

variable "default_labels" {
  description = "Labels par défaut à appliquer à toutes les règles"
  type        = map(string)
  default     = {
    environment = "qa"
    team        = "platform"
  }
}

variable "kubernetes_apps_rules" {
  description = "Règles d'alertes pour les applications Kubernetes"
  type        = list(object({
    name        = string
    expr        = string
    for         = string
    annotations = map(string)
    labels      = map(string)
  }))
  default     = []
}

variable "kubernetes_resources_rules" {
  description = "Règles d'alertes pour les ressources Kubernetes"
  type        = list(object({
    name        = string
    expr        = string
    for         = string
    annotations = map(string)
    labels      = map(string)
  }))
  default     = []
}

variable "kubernetes_storage_rules" {
  description = "Règles d'alertes pour le stockage Kubernetes"
  type        = list(object({
    name        = string
    expr        = string
    for         = string
    annotations = map(string)
    labels      = map(string)
  }))
  default     = []
}

variable "kubernetes_system_rules" {
  description = "Règles d'alertes pour le système Kubernetes"
  type        = list(object({
    name        = string
    expr        = string
    for         = string
    annotations = map(string)
    labels      = map(string)
  }))
  default     = []
}

variable "kube_apiserver_availability_rules" {
  description = "Règles d'enregistrement pour la disponibilité de l'API Server"
  type        = list(object({
    record      = string
    expr        = string
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})
  }))
  default     = []
}

variable "kube_apiserver_burnrate_rules" {
  description = "Règles d'enregistrement pour le burn rate de l'API Server"
  type        = list(object({
    record      = string
    expr        = string
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})
  }))
  default     = []
}

variable "kube_apiserver_histogram_rules" {
  description = "Règles d'enregistrement pour les histogrammes de l'API Server"
  type        = list(object({
    record      = string
    expr        = string
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})
  }))
  default     = []
}

variable "k8s_rules" {
  description = "Règles d'enregistrement générales Kubernetes"
  type        = list(object({
    record      = string
    expr        = string
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})
  }))
  default     = []
}

variable "kube_scheduler_rules" {
  description = "Règles d'enregistrement pour le scheduler Kubernetes"
  type        = list(object({
    record      = string
    expr        = string
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})
  }))
  default     = []
}

variable "node_rules" {
  description = "Règles d'enregistrement pour les nodes"
  type        = list(object({
    record      = string
    expr        = string
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})
  }))
  default     = []
}

variable "kubelet_rules" {
  description = "Règles d'enregistrement pour kubelet"
  type        = list(object({
    record      = string
    expr        = string
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})
  }))
  default     = []
} 