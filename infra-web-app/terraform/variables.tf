variable "location" {
  description = "The Azure region to deploy resources"
  default     = "East US"
}

variable "admin_username" {
  description = "Admin username for the VMs"
  default     = "acmeadmin"
}

variable "admin_password" {
  description = "Admin password for the VMs"
  default     = "YourPassword123!"
}

variable "vm_count" {
  description = "Number of VMs to create"
  default     = 2
}

variable "ssh_key_path" {
  description = "Path to the SSH public key"
  default     = "terraform/private_key.pem"
}
