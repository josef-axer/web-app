resource "random_pet" "ssh_key_name" {
  prefix    = "ssh"
  separator = ""
}

resource "azapi_resource" "ssh_public_key" {
  type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  name      = random_pet.ssh_key_name.id
  location  = azurerm_resource_group.acme.location
  parent_id = azurerm_resource_group.acme.id
}

resource "azapi_resource_action" "ssh_public_key_gen" {
  type                   = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  resource_id            = azapi_resource.ssh_public_key.id
  action                 = "generateKeyPair"
  method                 = "POST"
  response_export_values = ["publicKey", "privateKey"]
}

resource "local_file" "private_key" {
  content  = azapi_resource_action.ssh_public_key_gen.output.privateKey
  filename = "${path.module}/private_key.pem"
}

output "private_key_path" {
  value = "${path.module}/private_key.pem"
}