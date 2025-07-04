# Terraform Project for Grafana - Kubernetes Alerts

This project automatically deploys Prometheus alerts and recording rules in Grafana from source YAML files.

## 🏗️ Architecture

```
grafana-tf/
├── environments/           # Environment-specific configurations
│   ├── qa/                # Qualification environment
│   │   ├── main.tf        # Main configuration
│   │   ├── variables.tf   # Variables
│   │   ├── terraform.tfvars # Variable values
│   │   └── generated_variables.tfvars # Generated variables from YAML
│   ├── prod/              # Production (to be created)
│   └── lab/               # Laboratory (to be created)
├── modules/               # Reusable Terraform modules
│   ├── alert_rules/       # Module for alert rules
│   ├── kubernetes_alerts/ # Kubernetes specialized module
│   └── notification_channels/ # Module for notification channels
├── yaml_files/            # Source YAML files
│   ├── prometheus_alerts.yaml
│   └── prometheus_rules.yaml
└── script/                # Utility scripts
    └── yaml_to_terraform.py # YAML → Terraform conversion
```

## 🚀 Installation and Configuration

### Prerequisites

1. **Terraform** >= 1.0
2. **Python** >= 3.8 with PyYAML
3. **Grafana** >= 9.0 with API enabled
4. **Grafana API Token** with write permissions

### Configuration

1. **Clone and prepare the environment:**
```bash
git clone <repository>
cd grafana-tf
python3 -m venv venv
source venv/bin/activate
pip install PyYAML
```

2. **Configure Grafana authentication:**
```bash
# Edit the terraform.tfvars file
cp environments/qa/terraform.tfvars.example environments/qa/terraform.tfvars
```

Modify `environments/qa/terraform.tfvars`:
```hcl
grafana_url = "http://your-grafana:3000"
grafana_auth_token = "your-api-token"
```

3. **Generate Terraform variables:**
```bash
python script/yaml_to_terraform.py qa
```

## 📊 Usage

### Deployment

```bash
cd environments/qa
terraform init
terraform plan -var-file="terraform.tfvars" -var-file="generated_variables.tfvars"
terraform apply -var-file="terraform.tfvars" -var-file="generated_variables.tfvars"
```

### Updating alerts

1. Modify YAML files in `yaml_files/`
2. Regenerate variables:
```bash
python script/yaml_to_terraform.py qa
```
3. Apply changes:
```bash
cd environments/qa
terraform plan -var-file="terraform.tfvars" -var-file="generated_variables.tfvars"
terraform apply -var-file="terraform.tfvars" -var-file="generated_variables.tfvars"
```

## 📁 Modules

### `kubernetes_alerts`
- Creates Grafana folders organized by alert type
- Generates alert and recording rule groups
- Automatically processes YAML files

### `alert_rules`
- Generic module for creating alert rules
- Support for custom annotations and labels
- Flexible threshold configuration

### `notification_channels`
- Configuration of notification channels (email, Slack, etc.)
- Support for notification policies
- Alert resolution management

## 📝 Generated Content

The `yaml_to_terraform.py` script automatically generates:

- **60 alert rules** distributed across 4 categories:
  - Kubernetes Applications (25 rules)
  - Kubernetes Resources (9 rules)
  - Kubernetes Storage (5 rules)  
  - Kubernetes System (21 rules)

- **71 recording rules** for:
  - API Server availability
  - API Server burn rate
  - API Server histograms
  - General K8s metrics
  - Scheduler, Nodes, Kubelet

## 🔧 Advanced Configuration

### Custom Variables

In `terraform.tfvars`, you can configure:

```hcl
# Notification channels
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

# Custom alert rules
alert_rules = {
  custom_alert = {
    name        = "Service Down"
    description = "A critical service is unavailable"
    query       = "up{job=\"my-service\"} == 0"
    duration    = "5m"
  }
}
```

### Tags and Labels

```hcl
common_tags = {
  Environment = "qa"
  Team        = "platform"
  Project     = "monitoring"
  Owner       = "devops"
}
```

## 🔍 Troubleshooting

### Grafana authentication error
```
Error: [GET /folders/{folder_uid}][401] getFolderByUidUnauthorized
```
**Solution:** Verify that:
- Grafana is accessible at the configured URL
- API token is valid and has proper permissions
- Grafana organization is correct

### Terraform validation error
```
Error: Invalid multi-line string
```
**Solution:** Regenerate variables:
```bash
python script/yaml_to_terraform.py qa
```

### Module not found
```
Error: Module not found
```
**Solution:** Run `terraform init` in the environment directory.

## 📋 TODO

- [ ] Create `prod` and `lab` environments
- [ ] Add support for other providers (AWS CloudWatch, etc.)
- [ ] Implement Grafana dashboards
- [ ] Add automated tests
- [ ] Document custom metrics

## 🤝 Contributing

1. Fork the project
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Commit (`git commit -am 'Add new feature'`)
4. Push (`git push origin feature/new-feature`)
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License. See the `LICENSE` file for more details.