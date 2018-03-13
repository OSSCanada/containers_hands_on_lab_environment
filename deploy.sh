#! /bin/bash

export HOL_DEPLOYMENT_DIR=$(pwd)

if [ ! -f ~/.ssh/id_rsa ]; then
  echo "No ssh keys...generating one at ~/.ssh"
  ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
fi

terraform init terraform
terraform apply -auto-approve terraform

