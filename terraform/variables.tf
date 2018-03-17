variable "resource_group_name" {
  type        = "string"
  description = "Name of the azure resource group."
  default     = "containers-hol"
}

variable "resource_group_location" {
  type        = "string"
  description = "Location of the azure resource group."
  default     = "canadacentral"
}

variable "storage_account_tier" {
  type        = "string"
  description = "Storage account type Standard/Premium"
  default     = "Standard"
}

variable "storage_replication_type" {
  type        = "string"
  description = "storage replication type LRS/GRS/ZRS/RA-GRS"
  default     = "LRS"
}

variable "hostname" {
  type        = "string"
  description = "VM name referenced also in storage-related names."
  default     = "holjumpbox"
}

variable "vm_size" {
  type        = "string"
  description = "VM Size"
  default     = "Standard_DS2_v2"
}

variable "image_publisher" {
  description = "name of the publisher of the image (az vm image list)"
  default     = "Canonical"
}

variable "image_offer" {
  description = "the name of the offer (az vm image list)"
  default     = "UbuntuServer"
}

variable "image_sku" {
  description = "image sku to apply (az vm image list)"
  default     = "16.04-LTS"
}

variable "image_version" {
  description = "version of the image to apply (az vm image list)"
  default     = "latest"
}

variable "admin_username" {
  type        = "string"
  description = "Admin username for jumpbox VM"
  default     = "holadmin"
}
