variable "env" {}

variable "product" {
  default = "mailrelay"
}

variable "location" {
  default = "uksouth"
}

variable "product_group_object_id" {
  type        = string
  default     = "e7ea2042-4ced-45dd-8ae3-e051c6551789"
  description = "DTS Platform Operations"
}

variable "builtFrom" {}

variable "expiresAfter" {
  description = "Date when Sandbox resources can be deleted. Format: YYYY-MM-DD"
  default     = "3000-01-01"
}