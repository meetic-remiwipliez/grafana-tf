# Projet Terraform pour Grafana - Alertes Kubernetes

Ce projet permet de déployer automatiquement des alertes et règles d'enregistrement Prometheus dans Grafana à partir de fichiers YAML sources.

## 🏗️ Architecture

```
grafana-tf/
├── environments/           # Configurations par environnement
│   ├── qa/                # Environnement de qualification
│   │   ├── main.tf        # Configuration principale
│   │   ├── variables.tf   # Variables
│   │   ├── terraform.tfvars # Valeurs des variables
│   │   └── generated_variables.tfvars # Variables générées depuis YAML
│   ├── prod/              # Production (à créer)
│   └── lab/               # Laboratoire (à créer)
├── modules/               # Modules Terraform réutilisables
│   ├── alert_rules/       # Module pour les règles d'alertes
│   ├── kubernetes_alerts/ # Module spécialisé Kubernetes
│   └── notification_channels/ # Module pour les canaux de notification
├── yaml_files/            # Fichiers YAML sources
│   ├── prometheus_alerts.yaml
│   └── prometheus_rules.yaml
└── script/                # Scripts utilitaires
    └── yaml_to_terraform.py # Conversion YAML → Terraform
```

## 🚀 Installation et Configuration

### Prérequis

1. **Terraform** >= 1.0
2. **Python** >= 3.8 avec PyYAML
3. **Grafana** >= 9.0 avec API activée
4. **Token API Grafana** avec permissions d'écriture

### Configuration

1. **Cloner et préparer l'environnement :**
```bash
git clone <repository>
cd grafana-tf
python3 -m venv venv
source venv/bin/activate
pip install PyYAML
```

2. **Configurer l'authentification Grafana :**
```bash
# Éditer le fichier terraform.tfvars
cp environments/qa/terraform.tfvars.example environments/qa/terraform.tfvars
```

Modifier `environments/qa/terraform.tfvars` :
```hcl
grafana_url = "http://votre-grafana:3000"
grafana_auth_token = "votre-token-api"
```

3. **Générer les variables Terraform :**
```bash
python script/yaml_to_terraform.py qa
```

## 📊 Utilisation

### Déploiement

```bash
cd environments/qa
terraform init
terraform plan -var-file="terraform.tfvars" -var-file="generated_variables.tfvars"
terraform apply -var-file="terraform.tfvars" -var-file="generated_variables.tfvars"
```

### Mise à jour des alertes

1. Modifier les fichiers YAML dans `yaml_files/`
2. Régénérer les variables :
```bash
python script/yaml_to_terraform.py qa
```
3. Appliquer les changements :
```bash
cd environments/qa
terraform plan -var-file="terraform.tfvars" -var-file="generated_variables.tfvars"
terraform apply -var-file="terraform.tfvars" -var-file="generated_variables.tfvars"
```

## 📁 Modules

### `kubernetes_alerts`
- Crée les dossiers Grafana organisés par type d'alerte
- Génère les groupes de règles d'alertes et d'enregistrement
- Traite automatiquement les fichiers YAML

### `alert_rules`
- Module générique pour créer des règles d'alertes
- Support des annotations et labels personnalisés
- Configuration flexible des seuils

### `notification_channels`
- Configuration des canaux de notification (email, Slack, etc.)
- Support des politiques de notification
- Gestion des résolutions d'alertes

## 📝 Contenu Généré

Le script `yaml_to_terraform.py` génère automatiquement :

- **60 règles d'alertes** réparties en 4 catégories :
  - Applications Kubernetes (25 règles)
  - Ressources Kubernetes (9 règles)
  - Stockage Kubernetes (5 règles)  
  - Système Kubernetes (21 règles)

- **71 règles d'enregistrement** pour :
  - Disponibilité API Server
  - Burn rate API Server
  - Histogrammes API Server
  - Métriques générales K8s
  - Scheduler, Nodes, Kubelet

## 🔧 Configuration Avancée

### Variables Personnalisées

Dans `terraform.tfvars`, vous pouvez configurer :

```hcl
# Canaux de notification
notification_channels = {
  slack_alerts = {
    name         = "slack-alerts"
    type         = "slack"
    webhook_url  = "https://hooks.slack.com/..."
    send_resolved = true
  }
  email_ops = {
    name  = "email-ops"
    type  = "email"
    email = ["ops@example.com", "admin@example.com"]
  }
}

# Règles d'alertes personnalisées
alert_rules = {
  custom_alert = {
    name        = "Service Down"
    description = "Un service critique est indisponible"
    query       = "up{job=\"my-service\"} == 0"
    duration    = "5m"
  }
}
```

### Tags et Labels

```hcl
common_tags = {
  Environment = "qa"
  Team        = "platform"
  Project     = "monitoring"
  Owner       = "devops"
}
```

## 🔍 Dépannage

### Erreur d'authentification Grafana
```
Error: [GET /folders/{folder_uid}][401] getFolderByUidUnauthorized
```
**Solution :** Vérifier que :
- Grafana est accessible à l'URL configurée
- Le token API est valide et a les bonnes permissions
- L'organisation Grafana est correcte

### Erreur de validation Terraform
```
Error: Invalid multi-line string
```
**Solution :** Régénérer les variables :
```bash
python script/yaml_to_terraform.py qa
```

### Module non trouvé
```
Error: Module not found
```
**Solution :** Exécuter `terraform init` dans le répertoire de l'environnement.

## 📋 TODO

- [ ] Créer les environnements `prod` et `lab`
- [ ] Ajouter support pour d'autres providers (AWS CloudWatch, etc.)
- [ ] Implémenter les dashboards Grafana
- [ ] Ajouter tests automatisés
- [ ] Documentation des métriques custom

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Commit (`git commit -am 'Ajout nouvelle fonctionnalité'`)
4. Push (`git push origin feature/nouvelle-fonctionnalite`)
5. Créer une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.