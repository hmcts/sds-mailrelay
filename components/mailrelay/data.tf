data "azurerm_subscription" "current" {
}

data "azurerm_client_config" "current" {
}

data "azurerm_key_vault" "acme" {
  provider            = azurerm.control
  name                = "acmedtssdsprod"
  resource_group_name = "enterprise-prod-rg"
}

data "azurerm_user_assigned_identity" "mailrelay_mi" {
  name                = "mailrelay-${var.env}-mi"
  resource_group_name = "managed-identities-${var.env}-rg"
}