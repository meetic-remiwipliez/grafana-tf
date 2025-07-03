terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 3.0"
    }
  }
}

# Ressource pour créer les canaux de notification
resource "grafana_contact_point" "notification_channels" {
  for_each = var.channels

  name = each.value.name

  dynamic "email" {
    for_each = each.value.type == "email" ? [1] : []
    content {
      addresses               = each.value.email
      single_email            = length(each.value.email) == 1
      message                 = var.default_message
      subject                 = var.default_subject
      disable_resolve_message = !each.value.send_resolved
    }
  }

  dynamic "slack" {
    for_each = each.value.type == "slack" ? [1] : []
    content {
      url                     = lookup(each.value, "webhook_url", "")
      username                = lookup(each.value, "username", "Grafana")
      icon_emoji              = lookup(each.value, "icon_emoji", ":exclamation:")
      title                   = lookup(each.value, "title", "{{ template \"slack.default.title\" . }}")
      text                    = lookup(each.value, "text", "{{ template \"slack.default.text\" . }}")
      disable_resolve_message = !each.value.send_resolved
    }
  }

  dynamic "webhook" {
    for_each = each.value.type == "webhook" ? [1] : []
    content {
      url                     = lookup(each.value, "webhook_url", "")
      http_method             = lookup(each.value, "http_method", "POST")
      max_alerts              = lookup(each.value, "max_alerts", 0)
      disable_resolve_message = !each.value.send_resolved
    }
  }

  dynamic "pagerduty" {
    for_each = each.value.type == "pagerduty" ? [1] : []
    content {
      integration_key         = lookup(each.value, "integration_key", "")
      severity                = lookup(each.value, "severity", "error")
      component               = lookup(each.value, "component", "Grafana")
      group                   = lookup(each.value, "group", "")
      class                   = lookup(each.value, "class", "")
      disable_resolve_message = !each.value.send_resolved
    }
  }
}

# Politique de notification par défaut
resource "grafana_notification_policy" "default_policy" {
  count = var.create_default_policy ? 1 : 0

  contact_point = var.default_contact_point
  group_by      = var.default_group_by
  group_wait    = var.default_group_wait
  group_interval = var.default_group_interval
  repeat_interval = var.default_repeat_interval

  policy {
    contact_point = var.default_contact_point
    group_by      = var.default_group_by
    
    dynamic "matcher" {
      for_each = var.default_matchers
      content {
        label = matcher.value.label
        match = matcher.value.match
        value = matcher.value.value
      }
    }
  }
} 