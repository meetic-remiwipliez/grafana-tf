output "channels" {
  description = "Informations sur les canaux de notification créés"
  value = {
    for k, v in grafana_contact_point.notification_channels : k => {
      id   = v.id
      name = v.name
    }
  }
}

output "channel_names" {
  description = "Liste des noms des canaux créés"
  value       = [for channel in grafana_contact_point.notification_channels : channel.name]
}

output "channel_ids" {
  description = "Liste des IDs des canaux créés"
  value       = [for channel in grafana_contact_point.notification_channels : channel.id]
}

output "default_policy_id" {
  description = "ID de la politique de notification par défaut"
  value       = length(grafana_notification_policy.default_policy) > 0 ? grafana_notification_policy.default_policy[0].id : null
} 