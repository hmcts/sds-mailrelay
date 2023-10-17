module "ctags" {
  source      = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=master"
  environment = var.env
  product     = var.product
  builtFrom   = var.builtFrom
}

resource "azurerm_resource_group" "rg" {
  name     = "sds-${var.product}-${var.env}-rg"
  location = var.location
  tags     = module.ctags.common_tags
}

module "azurekeyvault" {
  source                  = "git::https://github.com/hmcts/cnp-module-key-vault?ref=master"
  name                    = "sds-${var.product}-${var.env}"
  product                 = var.product
  env                     = var.env
  resource_group_name     = azurerm_resource_group.rg.name
  product_group_object_id = var.product_group_object_id
  common_tags             = module.ctags.common_tags
  create_managed_identity = true
  object_id               = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "acme" {
  scope                = data.azurerm_key_vault.acme.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azurerm_user_assigned_identity.mailrelay_mi.principal_id
}

locals {
  # Needed for role assignment only
  wi_environment = var.env == "dev" ? "stg" : var.env
}

provider "azurerm" {
  subscription_id            = "74dacd4f-a248-45bb-a2f0-af700dc4cf68"
  skip_provider_registration = "true"
  features {}
  alias = "managed_identity_infra_sub"
}

resource "azurerm_user_assigned_identity" "managed_identity" {
  count               = var.env == "stg" ? 1 : 0
  provider            = azurerm.managed_identity_infra_sub
  name                = "${var.product}-${local.wi_environment}-mi"
  resource_group_name = "managed-identities-${local.wi_environment}-rg"
  location            = var.location
  tags                = module.ctags.common_tags
}

resource "azurerm_key_vault_access_policy" "managed_identity_access_policy" {
  count        = var.env == "stg" ? 1 : 0
  key_vault_id = module.azurekeyvault.key_vault_id

  object_id = azurerm_user_assigned_identity.managed_identity[count.index].principal_id
  tenant_id = data.azurerm_client_config.current.tenant_id

  key_permissions = [
    "Get",
    "List",
  ]

  certificate_permissions = [
    "Get",
    "List",
  ]

  secret_permissions = [
    "Get",
    "List",
  ]
}
