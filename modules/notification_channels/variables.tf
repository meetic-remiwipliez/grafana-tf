variable "channels" {
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

variable "tags" {
  description = "Tags à appliquer aux canaux de notification"
  type        = map(string)
  default     = {}
}

variable "default_message" {
  description = "Message par défaut pour les notifications email"
  type        = string
  default     = "{{ template \"email.default.message\" . }}"
}

variable "default_subject" {
  description = "Sujet par défaut pour les notifications email"
  type        = string
  default     = "{{ template \"email.default.subject\" . }}"
}

variable "create_default_policy" {
  description = "Créer une politique de notification par défaut"
  type        = bool
  default     = false
}

variable "default_contact_point" {
  description = "Point de contact par défaut"
  type        = string
  default     = "grafana-default-email"
}

variable "default_group_by" {
  description = "Groupement par défaut des alertes"
  type        = list(string)
  default     = ["grafana_folder", "alertname"]
}

variable "default_group_wait" {
  description = "Temps d'attente avant d'envoyer la première notification"
  type        = string
  default     = "10s"
}

variable "default_group_interval" {
  description = "Temps d'attente avant d'envoyer des notifications supplémentaires"
  type        = string
  default     = "5m"
}

variable "default_repeat_interval" {
  description = "Temps d'attente avant de répéter les notifications"
  type        = string
  default     = "12h"
}

variable "default_matchers" {
  description = "Matchers par défaut pour la politique de notification"
  type = list(object({
    label = string
    match = string
    value = string
  }))
  default = []
} 