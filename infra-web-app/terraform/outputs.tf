output "ansible_inventory" {
  value = templatefile("${path.module}/../ansible/inventory.tpl", {
    vm1_ip = azurerm_public_ip.acme_ip[0].ip_address,
    vm2_ip = azurerm_public_ip.acme_ip[1].ip_address,
    private_key_path = "${path.module}/private_key.pem"
  })
}

output "public_ips" {
  value = azurerm_public_ip.acme_ip[*].ip_address
}
