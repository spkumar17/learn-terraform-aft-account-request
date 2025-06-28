# 📘 AFT Account Request Module

A Terraform module for provisioning new AWS accounts using **Account Factory for Terraform (AFT)** with AWS Control Tower. This module automates account creation, user access configuration, tagging, and custom account setups.

---

## 🚀 Quick Start

```hcl
module "new_account" {
  source = "./path-to-this-module"

  control_tower_parameters = {
    AccountEmail              = "example-app@company.com"
    AccountName               = "example-application-account"
    ManagedOrganizationalUnit = "Workload-OU"
    SSOUserEmail              = "admin@company.com"
    SSOUserFirstName          = "John"
    SSOUserLastName           = "Doe"
  }

  account_tags = {
    "Environment" = "production"
    "Team"        = "platform-engineering"
    "CostCenter"  = "engineering"
  }

  change_management_parameters = {
    change_requested_by = "Platform Team"
    change_reason       = "New application deployment account"
  }

  custom_fields = {
    group = "prod"
  }

  account_customizations_name = "ApplicationFactoryAccountRequest"
}
```

---

## 🔧 What This Module Does

When you apply this module, it will:

✅ **Create a new AWS account** in AWS Control Tower  
✅ **Assign an IAM Identity Center (SSO) user** to that account  
✅ **Apply custom tags and metadata** for organization  
✅ **Run account-specific Terraform customizations** post-creation  
✅ **Integrate with AWS Organizations** for governance  

---

## 📋 Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |
| Account Factory for Terraform (AFT) | Deployed and configured |
| AWS Control Tower | Active and configured |
| IAM Identity Center (AWS SSO) | Enabled |

### Prerequisites

- [ ] AFT deployed in your AWS environment
- [ ] AWS Control Tower set up with organizational units
- [ ] IAM Identity Center configured
- [ ] Appropriate permissions to create accounts

---

## 🧩 Input Parameters

### `control_tower_parameters`

Core settings for the new AWS account creation.

| Parameter | Type | Description | Required |
|-----------|------|-------------|----------|
| `AccountEmail` | `string` | Email address for the AWS account root user | ✅ |
| `AccountName` | `string` | Display name for the AWS account | ✅ |
| `ManagedOrganizationalUnit` | `string` | Target OU for account placement | ✅ |
| `SSOUserEmail` | `string` | IAM Identity Center user email for account access | ✅ |
| `SSOUserFirstName` | `string` | First name of the SSO user | ✅ |
| `SSOUserLastName` | `string` | Last name of the SSO user | ✅ |

### `account_tags`

Key-value pairs for tagging the AWS account.

```hcl
account_tags = {
  "Environment"   = "production"
  "Team"          = "platform-engineering"
  "CostCenter"    = "engineering"
  "Project"       = "web-application"
  "Managed-By"    = "AFT"
}
```

### `change_management_parameters`

Audit and tracking information for the account creation.

| Parameter | Type | Description |
|-----------|------|-------------|
| `change_requested_by` | `string` | Who is requesting the account creation |
| `change_reason` | `string` | Business justification for the account |

### `custom_fields`

User-defined metadata for custom behaviors and logic.

```hcl
custom_fields = {
  group           = "prod"          # Environment grouping
  backup_schedule = "daily"         # Custom backup requirements
  compliance_tier = "high"          # Security/compliance level
}
```

### `account_customizations_name`

Specifies which customization folder AFT should execute post-account creation.

```
customizations/
└── ApplicationFactoryAccountRequest/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

---

## 📁 Directory Structure

```
your-aft-repo/
├── account-requests/
│   └── main.tf                    # This module usage
├── customizations/
│   └── ApplicationFactoryAccountRequest/
│       ├── main.tf               # Account-specific customizations
│       ├── variables.tf
│       └── outputs.tf
└── global-customizations/
    └── main.tf                   # Org-wide customizations
```

---

## 🎯 Usage Examples

### Development Account

```hcl
module "dev_account" {
  source = "./aft-account-request"

  control_tower_parameters = {
    AccountEmail              = "dev-team@company.com"
    AccountName               = "development-sandbox"
    ManagedOrganizationalUnit = "Development-OU"
    SSOUserEmail              = "dev-admin@company.com"
    SSOUserFirstName          = "Development"
    SSOUserLastName           = "Admin"
  }

  account_tags = {
    "Environment" = "development"
    "AutoShutdown" = "enabled"
  }

  custom_fields = {
    group = "non-prod"
    cost_optimization = "aggressive"
  }

  account_customizations_name = "DevelopmentAccountSetup"
}
```

### Production Account

```hcl
module "prod_account" {
  source = "./aft-account-request"

  control_tower_parameters = {
    AccountEmail              = "prod-app@company.com"
    AccountName               = "production-application"
    ManagedOrganizationalUnit = "Production-OU"
    SSOUserEmail              = "prod-admin@company.com"
    SSOUserFirstName          = "Production"
    SSOUserLastName           = "Admin"
  }

  account_tags = {
    "Environment" = "production"
    "Criticality" = "high"
    "Monitoring"  = "enhanced"
  }

  custom_fields = {
    group = "prod"
    backup_schedule = "continuous"
    compliance_tier = "sox"
  }

  account_customizations_name = "ProductionAccountSetup"
}
```

---

## 🔄 Workflow

1. **Plan**: Review the account configuration
   ```bash
   terraform plan
   ```

2. **Apply**: Create the account request
   ```bash
   terraform apply
   ```

3. **Monitor**: AFT processes the request asynchronously
   - Check AWS Control Tower console
   - Monitor AFT pipeline in CodePipeline

4. **Validation**: Verify account creation and customizations
   - Account appears in AWS Organizations
   - SSO user has access
   - Custom resources are deployed

---

## 🛡️ Security Considerations

- **Email Uniqueness**: Each `AccountEmail` must be unique across all AWS accounts
- **SSO Permissions**: Ensure SSO user has appropriate permission sets
- **OU Placement**: Verify the target OU has correct SCPs applied
- **Customizations**: Review custom Terraform code for security best practices

---

## 🔍 Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Email already exists | Use a unique email address |
| OU doesn't exist | Create the OU in AWS Organizations first |
| SSO user not found | Ensure user exists in IAM Identity Center |
| Customization fails | Check CloudWatch logs in AFT management account |

### Useful Commands

```bash
# Check AFT pipeline status
aws codepipeline get-pipeline-state --name aft-account-provisioning-framework

# View account creation logs
aws logs describe-log-groups --log-group-name-prefix "/aws/codebuild/aft"
```

---

## 📚 Additional Resources

- [AWS Control Tower User Guide](https://docs.aws.amazon.com/controltower/)
- [Account Factory for Terraform](https://docs.aws.amazon.com/controltower/latest/userguide/aft-overview.html)
- [AWS Organizations Documentation](https://docs.aws.amazon.com/organizations/)
- [IAM Identity Center Documentation](https://docs.aws.amazon.com/singlesignon/)

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

## 📄 License

This module is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

---

## 📞 Support

For questions or issues:
- Create an issue in this repository
- Contact the Platform Engineering team
- Refer to AWS documentation

---

**Made with ❤️ by the Platform Engineering Team**