# 🔄 Managing Existing AWS Accounts with AFT

A comprehensive guide for onboarding and managing existing AWS accounts using **Account Factory for Terraform (AFT)**. This documentation covers the complete process of bringing existing accounts under AFT management without recreating them.

---

## 🎯 Overview

AFT can manage existing AWS accounts by taking over their lifecycle management while preserving the accounts themselves. This process allows you to:

✅ **Apply standardized configurations** to existing accounts  
✅ **Implement governance and compliance** across your entire AWS organization  
✅ **Centralize account management** without disrupting existing workloads  
✅ **Enable consistent customizations** across all accounts  

---

## ❓ Can AFT Manage Existing Accounts?

**Yes** — AFT can manage existing accounts, but with important considerations:

| ✅ What AFT Will Do | ❌ What AFT Won't Do |
|---------------------|----------------------|
| Apply global/account-specific customizations | Recreate existing accounts |
| Tag and organize accounts via AFT | Manage accounts outside your AWS Organization |
| Assign Identity Center users | Skip the account-request definition requirement |
| Maintain Terraform state for customizations | Modify existing account email or root settings |

---

## 🔧 Onboarding Process

### Step 1: Enable Existing Account Management

First, configure AFT to allow managing existing accounts by setting the feature flag:

```hcl
# In your AFT deployment configuration
aft_feature_flags = {
  aft_feature_existing_account_customizations = true
}
```

### Step 2: Create Account Request Module

Create an AFT account request for your existing account using the **exact** account details:

```hcl
module "existing_account_prod" {
  source = "../modules/aft-account-request"

  control_tower_parameters = {
    AccountEmail              = "your-existing-account-email@yourcompany.com"
    AccountName               = "prod"
    ManagedOrganizationalUnit = "Workload-OU"
    SSOUserEmail              = "user@example.com"
    SSOUserFirstName          = "Dev"
    SSOUserLastName           = "Ops"
  }

  account_tags = {
    "Environment" = "prod"
    "ManagedBy"   = "AFT"
    "OnboardedDate" = "2024-01-15"
  }

  change_management_parameters = {
    change_requested_by = "DevOps Team"
    change_reason       = "Bring existing prod account under AFT management"
  }

  custom_fields = {
    group = "prod"
    migration_status = "onboarded"
  }

  account_customizations_name = "prod-account"
}
```

### Step 3: Verify Prerequisites

Before onboarding, ensure:

- [ ] Account is part of your AWS Organization
- [ ] Account is in the correct Organizational Unit (OU)
- [ ] AFT has necessary permissions via `AWSControlTowerExecution` role
- [ ] Account email matches exactly what's in AWS
- [ ] IAM Identity Center users exist (if assigning access)

### Step 4: Execute the Pipeline

1. **Commit and Push**: Add your account request to the AFT repository
2. **Monitor Pipeline**: Watch the AFT CodePipeline execution
3. **Verify Results**: Check that customizations are applied successfully

---

## 📋 Multiple Existing Accounts Example

For organizations with multiple existing accounts:

```hcl
# Production Account
module "existing_prod" {
  source = "../modules/aft-account-request"

  control_tower_parameters = {
    AccountEmail              = "prod@company.com"
    AccountName               = "production"
    ManagedOrganizationalUnit = "Production-OU"
    SSOUserEmail              = "prod-admin@company.com"
    SSOUserFirstName          = "Production"
    SSOUserLastName           = "Admin"
  }

  account_tags = {
    "Environment" = "production"
    "Criticality" = "high"
    "ManagedBy"   = "AFT"
  }

  change_management_parameters = {
    change_requested_by = "Platform Team"
    change_reason       = "Standardize production account management"
  }

  custom_fields = {
    group = "prod"
    backup_schedule = "continuous"
  }

  account_customizations_name = "production-account"
}

# Staging Account
module "existing_staging" {
  source = "../modules/aft-account-request"

  control_tower_parameters = {
    AccountEmail              = "staging@company.com"
    AccountName               = "staging"
    ManagedOrganizationalUnit = "Non-Production-OU"
    SSOUserEmail              = "staging-admin@company.com"
    SSOUserFirstName          = "Staging"
    SSOUserLastName           = "Admin"
  }

  account_tags = {
    "Environment" = "staging"
    "ManagedBy"   = "AFT"
  }

  change_management_parameters = {
    change_requested_by = "Development Team"
    change_reason       = "Bring staging under AFT governance"
  }

  custom_fields = {
    group = "non-prod"
    auto_shutdown = "enabled"
  }

  account_customizations_name = "non-production-account"
}
```

---

## 🔍 Key Requirements

### Technical Prerequisites

| Requirement | Description | Status Check |
|-------------|-------------|--------------|
| **AWS Organization** | Account must be part of your organization | `aws organizations list-accounts` |
| **Control Tower** | Account must be enrolled in Control Tower | Check Control Tower console |
| **AFT Permissions** | AFT execution role must have access | Verify IAM roles and policies |
| **OU Placement** | Account in correct Organizational Unit | Check AWS Organizations structure |

### Configuration Requirements

```hcl
# Required AFT feature flag
aft_feature_flags = {
  aft_feature_existing_account_customizations = true
}

# Ensure AFT has proper permissions
aft_management_account_id = "123456789012"
ct_management_account_id  = "123456789012"
log_archive_account_id    = "123456789013"
audit_account_id          = "123456789014"
```

---

## 🚨 Important Considerations

### What Happens During Onboarding

1. **Account Detection**: AFT detects the account already exists
2. **State Import**: AFT imports the account into its Terraform state
3. **Customization Application**: Global and account-specific customizations are applied
4. **Ongoing Management**: Account becomes part of AFT lifecycle

### What Doesn't Change

- ✅ **Account ID** remains the same
- ✅ **Root user email** stays unchanged
- ✅ **Existing resources** are preserved
- ✅ **Account billing** continues normally
- ✅ **Existing IAM roles/policies** remain (unless customizations modify them)

### Potential Risks

| Risk | Mitigation |
|------|------------|
| **Resource Conflicts** | Review existing resources before applying customizations |
| **Permission Issues** | Ensure AFT roles have necessary permissions |
| **Customization Failures** | Test customizations in non-production first |
| **State Drift** | Monitor Terraform state and plan outputs |

---

## 🔧 Troubleshooting

### Common Issues

#### Account Not Found
```bash
Error: Account with email 'example@company.com' not found in organization
```
**Solution**: Verify the account email exactly matches what's in AWS Organizations.

#### Permission Denied
```bash
Error: Access denied when trying to assume AWSControlTowerExecution role
```
**Solution**: Check that AFT has proper cross-account role permissions.

#### OU Doesn't Exist
```bash
Error: Organizational Unit 'Workload-OU' not found
```
**Solution**: Create the OU in AWS Organizations or use an existing OU name.

#### Customization Failures
```bash
Error: Failed to apply account customizations
```
**Solution**: Check CloudWatch logs in the AFT management account for detailed error messages.

### Useful Commands

```bash
# List all accounts in organization
aws organizations list-accounts

# Check account OU placement
aws organizations list-parents --child-id 123456789012

# View AFT pipeline status
aws codepipeline get-pipeline-state --name aft-account-provisioning-framework

# Check customization logs
aws logs describe-log-groups --log-group-name-prefix "/aws/codebuild/aft"
```

---

## 📊 Monitoring and Validation

### Post-Onboarding Checklist

- [ ] Account appears in AFT dashboard
- [ ] Global customizations applied successfully
- [ ] Account-specific customizations deployed
- [ ] Tags applied correctly
- [ ] IAM Identity Center access configured
- [ ] No drift detected in Terraform state

### Ongoing Monitoring

```hcl
# Example monitoring customization
resource "aws_cloudwatch_dashboard" "aft_account_monitoring" {
  dashboard_name = "AFT-Account-${var.account_name}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        properties = {
          metrics = [
            ["AWS/Organizations", "AccountCount"],
            ["AWS/ControlTower", "DriftDetection"]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "AFT Account Health"
        }
      }
    ]
  })
}
```

---

## 🎯 Best Practices

### Before Onboarding

1. **Audit Existing Resources**: Document current account configuration
2. **Test Customizations**: Validate in a test environment first
3. **Backup Critical Data**: Ensure important configurations are backed up
4. **Plan Rollback**: Have a rollback strategy if issues occur

### During Onboarding

1. **Monitor Closely**: Watch pipeline execution and logs
2. **Validate Each Step**: Confirm each phase completes successfully
3. **Document Changes**: Keep track of what AFT modifies

### After Onboarding

1. **Regular Audits**: Periodically check for configuration drift
2. **Update Customizations**: Keep account customizations current
3. **Monitor Costs**: Track any cost changes from new resources
4. **Security Reviews**: Ensure security posture remains strong

---

## 📚 Additional Resources

- [AWS Control Tower User Guide](https://docs.aws.amazon.com/controltower/)
- [Account Factory for Terraform Documentation](https://docs.aws.amazon.com/controltower/latest/userguide/aft-overview.html)
- [AWS Organizations Best Practices](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_best-practices.html)
- [IAM Identity Center Configuration](https://docs.aws.amazon.com/singlesignon/)

---
