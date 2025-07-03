# Configuration pour l'environnement Lab
grafana_url = "http://localhost:3000"
grafana_auth_token = "glsa_b6SxCCK5iOS7yv6mf2A7lW7Acnxpg3sS_094c0d53"

# Tags communs
common_tags = {
  Environment = "qa"
  ManagedBy   = "terraform"
  Project     = "grafana-alerts"
}

# Canaux de notification (exemple)
notification_channels = {
  email_ops = {
    name         = "email-ops"
    type         = "email"
    email        = ["ops@example.com"]
    send_resolved = true
  }
}

# Règles d'alertes personnalisées (exemple)
alert_rules = {
  custom_test = {
    name        = "Custom Test Alert"
    description = "Test alert for validation"
    query       = "up == 0"
    duration    = "5m"
  }
}
