output "folders" {
  description = "Informations sur les dossiers créés"
  value = {
    kubernetes_apps = {
      id    = grafana_folder.kubernetes_apps.id
      uid   = grafana_folder.kubernetes_apps.uid
      title = grafana_folder.kubernetes_apps.title
      url   = grafana_folder.kubernetes_apps.url
    }
    kubernetes_resources = {
      id    = grafana_folder.kubernetes_resources.id
      uid   = grafana_folder.kubernetes_resources.uid
      title = grafana_folder.kubernetes_resources.title
      url   = grafana_folder.kubernetes_resources.url
    }
    kubernetes_storage = {
      id    = grafana_folder.kubernetes_storage.id
      uid   = grafana_folder.kubernetes_storage.uid
      title = grafana_folder.kubernetes_storage.title
      url   = grafana_folder.kubernetes_storage.url
    }
    kubernetes_system = {
      id    = grafana_folder.kubernetes_system.id
      uid   = grafana_folder.kubernetes_system.uid
      title = grafana_folder.kubernetes_system.title
      url   = grafana_folder.kubernetes_system.url
    }
    kubernetes_recording_rules = {
      id    = grafana_folder.kubernetes_recording_rules.id
      uid   = grafana_folder.kubernetes_recording_rules.uid
      title = grafana_folder.kubernetes_recording_rules.title
      url   = grafana_folder.kubernetes_recording_rules.url
    }
  }
}

output "rule_groups" {
  description = "Informations sur les groupes de règles créés"
  value = {
    kubernetes_apps = {
      id   = grafana_rule_group.kubernetes_apps.id
      name = grafana_rule_group.kubernetes_apps.name
    }
    kubernetes_resources = {
      id   = grafana_rule_group.kubernetes_resources.id
      name = grafana_rule_group.kubernetes_resources.name
    }
    kube_apiserver_availability = {
      id   = grafana_rule_group.kube_apiserver_availability.id
      name = grafana_rule_group.kube_apiserver_availability.name
    }
    kube_apiserver_burnrate = {
      id   = grafana_rule_group.kube_apiserver_burnrate.id
      name = grafana_rule_group.kube_apiserver_burnrate.name
    }
  }
}

output "alert_rules_count" {
  description = "Nombre de règles d'alertes créées par catégorie"
  value = {
    kubernetes_apps      = length(var.kubernetes_apps_rules)
    kubernetes_resources = length(var.kubernetes_resources_rules)
    kubernetes_storage   = length(var.kubernetes_storage_rules)
    kubernetes_system    = length(var.kubernetes_system_rules)
  }
}

output "recording_rules_count" {
  description = "Nombre de règles d'enregistrement créées par catégorie"
  value = {
    kube_apiserver_availability = length(var.kube_apiserver_availability_rules)
    kube_apiserver_burnrate     = length(var.kube_apiserver_burnrate_rules)
    kube_apiserver_histogram    = length(var.kube_apiserver_histogram_rules)
    k8s_rules                   = length(var.k8s_rules)
    kube_scheduler_rules        = length(var.kube_scheduler_rules)
    node_rules                  = length(var.node_rules)
    kubelet_rules               = length(var.kubelet_rules)
  }
} 