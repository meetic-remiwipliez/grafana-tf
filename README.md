# Terraform Project for Grafana - Kubernetes Alerts

This project deploys Prometheus alerts and recording rules in Grafana using Terraform modules. The QA environment is fully operational and serves as the reference for other environments.

## 🏗️ Architecture

```
grafana-tf/
├── environments/           # Environment-specific configurations
│   ├── qa/                # Qualification environment (operational)
│   │   ├── main.tf        # Main configuration
│   │   ├── variables.tf   # Variables
│   │   ├── terraform.tfvars # Variable values
│   │   └── generated_variables.tfvars # Alert and rule definitions
│   ├── prod/              # Production (copy tfvars from qa)
│   └── lab/               # Laboratory (copy tfvars from qa)
├── modules/               # Reusable Terraform modules
│   ├── alert_rules/       # Module for alert rules
│   ├── kubernetes_alerts/ # Kubernetes specialized module
│   └── notification_channels/ # Module for notification channels
└── yaml_files/            # Source YAML files (reference only)
    ├── prometheus_alerts.yaml
    └── prometheus_rules.yaml
```

## 🚀 Installation and Configuration

### Prerequisites

1. **Terraform** >= 1.0
2. **Grafana** >= 9.0 with API enabled
3. **Grafana API Token** with write permissions

### Configuration

1. **Clone the repository:**
```bash
git clone <repository>
cd grafana-tf
```

2. **Configure Grafana authentication:**

Edit `environments/qa/terraform.tfvars` (or copy to other environments):
```hcl
grafana_url = "http://your-grafana:3000"
grafana_auth_token = "your-api-token"
```

## 📊 Usage

### QA Environment (Reference)

The QA environment is fully configured and operational:

```bash
cd environments/qa
terraform init
terraform plan -var-file="terraform.tfvars" -var-file="generated_variables.tfvars"
terraform apply -var-file="terraform.tfvars" -var-file="generated_variables.tfvars"
```

### New Environment Setup

To deploy to a new environment (prod, lab):

1. **Copy configuration files from QA:**
```bash
# For production
cp environments/qa/main.tf environments/prod/
cp environments/qa/variables.tf environments/prod/
cp environments/qa/terraform.tfvars environments/prod/
cp environments/qa/generated_variables.tfvars environments/prod/

# For lab
cp environments/qa/main.tf environments/lab/
cp environments/qa/variables.tf environments/lab/
cp environments/qa/terraform.tfvars environments/lab/
cp environments/qa/generated_variables.tfvars environments/lab/
```

2. **Update environment-specific values:**
Edit the `terraform.tfvars` in the target environment to update:
- `grafana_url`
- `grafana_auth_token`
- Any environment-specific configurations

3. **Deploy:**
```bash
cd environments/[prod|lab]
terraform init
terraform plan -var-file="terraform.tfvars" -var-file="generated_variables.tfvars"
terraform apply -var-file="terraform.tfvars" -var-file="generated_variables.tfvars"
```

### Updating Alerts and Rules

To update alerts or rules across environments:

1. **Modify the reference configuration** in `environments/qa/generated_variables.tfvars`
2. **Test in QA:**
```bash
cd environments/qa
terraform plan -var-file="terraform.tfvars" -var-file="generated_variables.tfvars"
terraform apply -var-file="terraform.tfvars" -var-file="generated_variables.tfvars"
```
3. **Copy to other environments:**
```bash
cp environments/qa/generated_variables.tfvars environments/prod/
cp environments/qa/generated_variables.tfvars environments/lab/
```
4. **Apply to other environments:**
```bash
cd environments/prod
terraform plan -var-file="terraform.tfvars" -var-file="generated_variables.tfvars"
terraform apply -var-file="terraform.tfvars" -var-file="generated_variables.tfvars"
```

## 📁 Modules

### `kubernetes_alerts`
- Creates Grafana folders organized by alert type
- Generates alert and recording rule groups
- Processes predefined alert configurations

### `alert_rules`
- Generic module for creating alert rules
- Support for custom annotations and labels
- Flexible threshold configuration

### `notification_channels`
- Configuration of notification channels (email, Slack, etc.)
- Support for notification policies
- Alert resolution management

## 📝 Current Content

The system includes:

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

### Module not found
```
Error: Module not found
```
**Solution:** Run `terraform init` in the environment directory.

### State management
If you encounter state conflicts between environments, ensure each environment has its own state file and backend configuration.

## 📋 TODO

- [ ] Create `prod` and `lab` environments
- [ ] Add support for other providers (AWS CloudWatch, etc.)
- [ ] Implement Grafana dashboards
- [ ] Add automated tests
- [ ] Document custom metrics
- [ ] Set up remote state backend for production

## 🤝 Contributing

1. Fork the project
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Test changes in QA environment first
4. Commit (`git commit -am 'Add new feature'`)
5. Push (`git push origin feature/new-feature`)
6. Create a Pull Request

## 📄 License

This project is licensed under the MIT License. See the `LICENSE` file for more details.