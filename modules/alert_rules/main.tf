terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 3.0"
    }
  }
}

# Ressource pour créer un groupe de règles d'alertes
resource "grafana_rule_group" "alert_rules" {
  name             = var.name
  folder_uid       = var.folder_uid
  interval_seconds = var.interval_seconds

  dynamic "rule" {
    for_each = var.alert_rules

    content {
      name      = rule.value.name
      condition = "A"

      no_data_state  = var.no_data_state
      exec_err_state = var.exec_err_state
      for            = rule.value.window
      
      annotations = {
        summary     = rule.value.summary
        description = rule.value.description
        runbook_url = lookup(rule.value, "runbook_url", "")
      }
      
      labels = merge(
        var.tags,
        {
          severity = lookup(rule.value, "severity", "warning")
          group    = lookup(rule.value, "group", "default")
        }
      )
      
      is_paused = var.is_paused

      data {
        ref_id = "A"

        relative_time_range {
          from = var.query_time_range.from
          to   = var.query_time_range.to
        }

        datasource_uid = var.datasource_uid
        model = jsonencode({
          editorMode    = "code"
          expr          = rule.value.query
          intervalMs    = var.interval_ms
          maxDataPoints = var.max_data_points
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