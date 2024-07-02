[web]
acmeVM1 ansible_host=${vm1_ip}

[db]
acmeVM2 ansible_host=${vm2_ip}

[all:vars]
ansible_user=acmeadmin
ansible_ssh_private_key_file=${private_key_path}
