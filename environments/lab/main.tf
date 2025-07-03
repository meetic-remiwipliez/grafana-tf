terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 3.0"
    }
  }
}

provider "grafana" {
  url   = var.grafana_url
  auth  = var.grafana_auth_token
}

# Module principal pour les alertes Kubernetes
module "kubernetes_alerts" {
  source = "../../modules/kubernetes_alerts"

  datasource_uid   = "prometheus"
  interval_seconds = 60
  default_labels = {
    environment = "qa"
    team        = "platform"
  }

  # Variables pour les règles - alimentées par les scripts YAML
  kubernetes_apps_rules       = var.kubernetes_apps_rules
  kubernetes_resources_rules  = var.kubernetes_resources_rules
  kubernetes_storage_rules    = var.kubernetes_storage_rules
  kubernetes_system_rules     = var.kubernetes_system_rules
  
  # Variables pour les recording rules
  kube_apiserver_availability_rules = var.kube_apiserver_availability_rules
  kube_apiserver_burnrate_rules     = var.kube_apiserver_burnrate_rules
  kube_apiserver_histogram_rules    = var.kube_apiserver_histogram_rules
  k8s_rules                         = var.k8s_rules
  kube_scheduler_rules              = var.kube_scheduler_rules
  node_rules                        = var.node_rules
  kubelet_rules                     = var.kubelet_rules
}

# Configuration des canaux de notification
module "notification_channels" {
  source = "../../modules/notification_channels"

  channels = var.notification_channels
  tags     = var.common_tags
}

# Configuration des règles d'alertes supplémentaires
module "alert_rules" {
  source = "../../modules/alert_rules"

  name             = "QA Additional Alerts"
  folder_uid       = module.kubernetes_alerts.folders.kubernetes_apps.uid
  interval_seconds = 60
  alert_rules = [
    for name, rule in var.alert_rules : {
      name        = rule.name
      summary     = rule.description
      description = rule.description
      query       = rule.query
      window      = rule.duration
      severity    = "warning"
      group       = "qa-custom"
    }
  ]
  tags = var.common_tags
}

# Outputs
output "notification_channels" {
  description = "Canaux de notification créés"
  value       = module.notification_channels.channels
}

output "alert_rules" {
  description = "Règles d'alertes créées"
  value       = module.alert_rules.rules
}

output "kubernetes_folders" {
  description = "Dossiers Kubernetes créés"
  value       = module.kubernetes_alerts.folders
}

output "kubernetes_rule_groups" {
  description = "Groupes de règles Kubernetes créés"
  value       = module.kubernetes_alerts.rule_groups
}

# Fichiers importés
# Import des règles d'alertes
# Le fichier imported_alert_rules.tf contient les règles importées
# Import des points de contact
# Le fichier imported_contact_points.tf contient les points de contact importés

# Note: Les fichiers importés sont automatiquement inclus par Terraform
