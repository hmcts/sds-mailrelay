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
  wi_environment = var.env == "dev" ? "stg" : var.env
  # Reason for Prod Mailrelay2 creation here is that for each loop couldn't be passed into the key vault module to iterate over a list of product values (mailrelay and mailrelay2); the create_managed_identity flag above currently creates only Prod Mailrelay Managed Identity
  product_list = var.env == "prod" ? toset(["mailrelay2"]) : toset(["mailrelay", "mailrelay2"])
  managed_identity_subscription_id = {
    dev = {
      subscription = "74dacd4f-a248-45bb-a2f0-af700dc4cf68"
    }
    prod = {
      subscription = "5ca62022-6aa2-4cee-aaa7-e7536c8d566c"
    }
  }
}

provider "azurerm" {
  subscription_id            = local.managed_identity_subscription_id["${var.env}"].subscription
  skip_provider_registration = "true"
  features {}
  alias = "managed_identity_infra_sub"
}

resource "azurerm_user_assigned_identity" "managed_identity" {
  for_each            = local.product_list
  provider            = azurerm.managed_identity_infra_sub
  name                = "${each.value}-${local.wi_environment}-mi"
  resource_group_name = "managed-identities-${local.wi_environment}-rg"
  location            = var.location
  tags                = module.ctags.common_tags
}

resource "azurerm_key_vault_access_policy" "managed_identity_access_policy" {
  for_each     = local.product_list
  key_vault_id = module.azurekeyvault.key_vault_id

  object_id = azurerm_user_assigned_identity.managed_identity[each.value].principal_id
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
    "List"
  ]

}

resource "azurerm_role_assignment" "acme_kv" {
  for_each             = local.product_list
  scope                = data.azurerm_key_vault.acme.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.managed_identity[each.value].principal_id
}
