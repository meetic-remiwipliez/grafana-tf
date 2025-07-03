# Configuration pour l'environnement QA
grafana_url = "http://localhost:3000"
grafana_auth_token = "glsa_QLAwo7mIzD0SYZaE0JEFnfUZE94MsDO8_bc60aa7a"

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
