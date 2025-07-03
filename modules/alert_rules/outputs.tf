output "rule_group_id" {
  description = "ID du groupe de règles créé"
  value       = grafana_rule_group.alert_rules.id
}

output "rule_group_name" {
  description = "Nom du groupe de règles créé"
  value       = grafana_rule_group.alert_rules.name
}

output "rule_group_uid" {
  description = "UID du groupe de règles créé"
  value       = grafana_rule_group.alert_rules.id
}

output "rules" {
  description = "Liste des règles créées"
  value = [
    for rule in grafana_rule_group.alert_rules.rule : {
      name        = rule.name
      condition   = rule.condition
      for         = rule.for
      annotations = rule.annotations
      labels      = rule.labels
    }
  ]
}

output "folder_uid" {
  description = "UID du dossier utilisé"
  value       = var.folder_uid
} 