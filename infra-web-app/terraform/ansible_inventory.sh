#!/bin/bash
terraform apply -auto-approve

terraform output -raw ansible_inventory > ../ansible/inventory.ini

ansible-playbook -i ../ansible/inventory.ini ../ansible/playbook.yml