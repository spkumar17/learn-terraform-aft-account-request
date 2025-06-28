module "ApplicationFactoryAccountRequest" {
  source = "./modules/aft-account-request"

  control_tower_parameters = {
    AccountEmail              = "digitalagency89-App@gmail.com"
    AccountName               = "digitalagency89-App-production"
    ManagedOrganizationalUnit = "Workload-OU"
    SSOUserEmail              = "prasannakumarsinganamalla@gmail.com"
    SSOUserFirstName          = "prasannakumar"
    SSOUserLastName           = "Singanamalla"
  }

  account_tags = {
    "Account tag" = "AFT-Production"
  }

  change_management_parameters = {
    change_requested_by = "Prasanna Kumar Singanamalla"
    change_reason       = "Creating an AFT-managed account for Application Factory"

#     change_requested_by	Identifies who is requesting the change (can be a name, team, or system).
#     change_reason	Explains why the change (new account) is being made.
#     🧠 Note: These are not used by AWS directly but are useful for automation pipelines, logs, or internal tracking.
  }

  custom_fields = {
    group = "prod"
  }

  account_customizations_name = "ApplicationFactoryAccountRequest"
}
