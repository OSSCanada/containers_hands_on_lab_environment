#! /bin/bash

export HOL_DEPLOYMENT_DIR=$(pwd)

if [ ! -f ~/.ssh/id_rsa ]; then
  echo "No ssh keys...generating one at ~/.ssh"
  ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
fi

cd terraform

terraform init
terraform apply -auto-approve

if [ $? -eq 0 ]; then
  export HOL_JUMPBOX_ADMIN_USERNAME=$(terraform ouput jumpbox_admin_username)
  export HOL_JUMPBOX_FQDN=$(terraform output jumpbox_fqdn)

  echo "Jumpbox admin username $HOL_JUMPBOX_ADMIN_USERNAME"
  echo "Jumpbox FQDN $HOLD_JUMPBOX_FQDN"
else
  echo "Terraform Deployment Failed."
fi

cd $HOL_DEPLOYMENT_DIR/ansible

# ansible all -i "$HOL_JUMPBOX_FQDN," -u $HOL_JUMPBOX_ADMIN_USERNAME
ansible-playbook playbooks/PLAYBOOK_NAME.yml --limit "$HOL_JUMPBOX_FQDN" -u $HOL_JUMPBOX_ADMIN_USERNAME