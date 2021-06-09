resource "azurerm_user_assigned_identity" "mailrelay_mi" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  name = "mailrelay-${var.environment}-mi"

  tags = local.common_tags
}

resource "azurerm_role_assignment" "mailrelay_mi" {
  scope                = "${data.azurerm_subscription.current.id}/resourceGroups/${azurerm_resource_group.rg.name}/providers/Microsoft.KeyVault/vaults/${module.azurekeyvault.name}"
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.mailrelay_mi.principal_id
}
