variable "env" {
    default = "dev"
}

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