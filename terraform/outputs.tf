output "jumpbox_username" {
  value = "${azurerm_virtual_machine.jumpbox.name}"
}

output "jumpbox_hostname" {
  value = "${azurerm_virtual_machine.jumpbox.name}"
}

output "jumpbox_fqdn" {
  value = "${azurerm_public_ip.pip.fqdn}"
}

output "ssh_command" {
  value = "ssh ${var.admin_username}@${azurerm_public_ip.pip.fqdn}"
}
