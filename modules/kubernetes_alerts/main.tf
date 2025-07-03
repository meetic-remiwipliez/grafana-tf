terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 3.0"
    }
  }
}

# Dossiers pour organiser les alertes
resource "grafana_folder" "kubernetes_apps" {
  title = "Kubernetes Apps"
  uid   = "kubernetes-apps"
}

resource "grafana_folder" "kubernetes_resources" {
  title = "Kubernetes Resources"
  uid   = "kubernetes-resources"
}

resource "grafana_folder" "kubernetes_storage" {
  title = "Kubernetes Storage"
  uid   = "kubernetes-storage"
}

resource "grafana_folder" "kubernetes_system" {
  title = "Kubernetes System"
  uid   = "kubernetes-system"
}

resource "grafana_folder" "kubernetes_recording_rules" {
  title = "Kubernetes Recording Rules"
  uid   = "kubernetes-recording-rules"
}

# Groupes d'alertes Kubernetes Apps
resource "grafana_rule_group" "kubernetes_apps" {
  name             = "kubernetes-apps"
  folder_uid       = grafana_folder.kubernetes_apps.uid
  interval_seconds = var.interval_seconds

  dynamic "rule" {
    for_each = var.kubernetes_apps_rules

    content {
      name      = rule.value.name
      condition = "A"

      no_data_state  = "NoData"
      exec_err_state = "Alerting"
      for            = rule.value.for
      
      annotations = rule.value.annotations
      labels      = merge(var.default_labels, rule.value.labels)
      is_paused   = false

      data {
        ref_id = "A"

        relative_time_range {
          from = 600
          to   = 0
        }

        datasource_uid = var.datasource_uid
        model = jsonencode({
          editorMode    = "code"
          expr          = rule.value.expr
          intervalMs    = 1000
          maxDataPoints = 43200
          refId         = "A"
          hide          = false
          instant       = true
          legendFormat  = "__auto"
          range         = false
          datasource = {
            type = "prometheus"
            uid  = var.datasource_uid
          }
        })
      }
    }
  }
}

# Groupes d'alertes Kubernetes Resources
resource "grafana_rule_group" "kubernetes_resources" {
  name             = "kubernetes-resources"
  folder_uid       = grafana_folder.kubernetes_resources.uid
  interval_seconds = var.interval_seconds

  dynamic "rule" {
    for_each = var.kubernetes_resources_rules

    content {
      name      = rule.value.name
      condition = "A"

      no_data_state  = "NoData"
      exec_err_state = "Alerting"
      for            = rule.value.for
      
      annotations = rule.value.annotations
      labels      = merge(var.default_labels, rule.value.labels)
      is_paused   = false

      data {
        ref_id = "A"

        relative_time_range {
          from = 600
          to   = 0
        }

        datasource_uid = var.datasource_uid
        model = jsonencode({
          editorMode    = "code"
          expr          = rule.value.expr
          intervalMs    = 1000
          maxDataPoints = 43200
          refId         = "A"
          hide          = false
          instant       = true
          legendFormat  = "__auto"
          range         = false
          datasource = {
            type = "prometheus"
            uid  = var.datasource_uid
          }
        })
      }
    }
  }
}

# Recording Rules - Kube API Server Availability
resource "grafana_rule_group" "kube_apiserver_availability" {
  name             = "kube-apiserver-availability.rules"
  folder_uid       = grafana_folder.kubernetes_recording_rules.uid
  interval_seconds = 180 # 3 minutes

  dynamic "rule" {
    for_each = var.kube_apiserver_availability_rules

    content {
      name      = rule.value.record
      condition = "A"

      no_data_state  = "NoData"
      exec_err_state = "Alerting"
      for            = "0s"
      
      annotations = lookup(rule.value, "annotations", {})
      labels      = merge(var.default_labels, lookup(rule.value, "labels", {}))
      is_paused   = false

      data {
        ref_id = "A"

        relative_time_range {
          from = 600
          to   = 0
        }

        datasource_uid = var.datasource_uid
        model = jsonencode({
          editorMode    = "code"
          expr          = rule.value.expr
          intervalMs    = 1000
          maxDataPoints = 43200
          refId         = "A"
          hide          = false
          instant       = true
          legendFormat  = "__auto"
          range         = false
          datasource = {
            type = "prometheus"
            uid  = var.datasource_uid
          }
        })
      }
    }
  }
}

# Recording Rules - Kube API Server Burnrate
resource "grafana_rule_group" "kube_apiserver_burnrate" {
  name             = "kube-apiserver-burnrate.rules"
  folder_uid       = grafana_folder.kubernetes_recording_rules.uid
  interval_seconds = var.interval_seconds

  dynamic "rule" {
    for_each = var.kube_apiserver_burnrate_rules

    content {
      name      = rule.value.record
      condition = "A"

      no_data_state  = "NoData"
      exec_err_state = "Alerting"
      for            = "0s"
      
      annotations = lookup(rule.value, "annotations", {})
      labels      = merge(var.default_labels, lookup(rule.value, "labels", {}))
      is_paused   = false

      data {
        ref_id = "A"

        relative_time_range {
          from = 600
          to   = 0
        }

        datasource_uid = var.datasource_uid
        model = jsonencode({
          editorMode    = "code"
          expr          = rule.value.expr
          intervalMs    = 1000
          maxDataPoints = 43200
          refId         = "A"
          hide          = false
          instant       = true
          legendFormat  = "__auto"
          range         = false
          datasource = {
            type = "prometheus"
            uid  = var.datasource_uid
          }
        })
      }
    }
  }
} 