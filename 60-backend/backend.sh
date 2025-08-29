#!/bin/bash


dnf install ansible -y

#push
#ansible-playbook -i inventory mysql.yaml

#pull # ansible pull --> ansible documentation
ansible-pull -i localhost, -U  https://github.com/poojarivinod/expense-ansible-roles-tf.git main.yaml -e COMPONENT=backend -e ENVIRONMENT=$1
# ansible will clone the repository from above url and it will take main.yaml file
# -i for host, -u for source, -e for command line
# ENVIRONMENT is ansible variable, $1 is the shell variable, here $1 is dev
# ENVIRONMENT=$1 to receive the ${var.environment} from the main.tf
# (-U) in this U should be capital letter 