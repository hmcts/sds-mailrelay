resource "azurerm_resource_group" "rg" {
  name     = "sds-${var.product}-${var.environment}-rg"
  location = var.location
  tags     = local.common_tags
}

module "azurekeyvault" {
  source                  = "git::https://github.com/hmcts/cnp-module-key-vault?ref=master"
  name                    = "sds${var.product}-${var.environment}"
  product                 = var.product
  env                     = var.environment
  resource_group_name     = azurerm_resource_group.rg.name
  product_group_name      = "DTS Platform Operations"
  common_tags             = local.common_tags
  create_managed_identity = true
  object_id               = data.azurerm_client_config.current.object_id
}
