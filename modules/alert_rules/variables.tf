variable "name" {
  description = "Nom du groupe de règles d'alertes"
  type        = string
}

variable "folder_uid" {
  description = "UID du dossier Grafana où créer les règles"
  type        = string
}

variable "interval_seconds" {
  description = "Intervalle d'évaluation des règles en secondes"
  type        = number
  default     = 60
}

variable "alert_rules" {
  description = "Liste des règles d'alertes à créer"
  type = list(object({
    name        = string
    summary     = string
    description = string
    query       = string
    window      = string
    severity    = optional(string, "warning")
    group       = optional(string, "default")
    runbook_url = optional(string, "")
    datasource  = optional(string, "prometheus")
  }))
}

variable "tags" {
  description = "Tags à appliquer aux règles"
  type        = map(string)
  default     = {}
}

variable "datasource_uid" {
  description = "UID de la source de données Prometheus"
  type        = string
  default     = "prometheus"
}

variable "no_data_state" {
  description = "État de l'alerte quand il n'y a pas de données"
  type        = string
  default     = "NoData"
  
  validation {
    condition     = contains(["NoData", "Alerting", "OK"], var.no_data_state)
    error_message = "no_data_state doit être NoData, Alerting, ou OK."
  }
}

variable "exec_err_state" {
  description = "État de l'alerte en cas d'erreur d'exécution"
  type        = string
  default     = "Alerting"
  
  validation {
    condition     = contains(["Alerting", "OK"], var.exec_err_state)
    error_message = "exec_err_state doit être Alerting ou OK."
  }
}

variable "is_paused" {
  description = "Indique si les règles sont en pause"
  type        = bool
  default     = false
}

variable "query_time_range" {
  description = "Plage de temps pour les requêtes"
  type = object({
    from = number
    to   = number
  })
  default = {
    from = 600
    to   = 0
  }
}

variable "interval_ms" {
  description = "Intervalle en millisecondes pour les requêtes"
  type        = number
  default     = 1000
}

variable "max_data_points" {
  description = "Nombre maximum de points de données"
  type        = number
  default     = 43200
} 