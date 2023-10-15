# rails_ansible_presentation_2023


##### Build do projeto

docker-compose build

#### Executando o shell

docker-compose run --rm --service-ports web bash

#### Executando local

rails s -p 3015 -b 0.0.0.0


#### Link com a apresentação:

https://docs.google.com/presentation/d/12hNHkNSkZuUBAQllnQJ4R3IKOfdVeLjQtL4ZizWs6lU/edit?usp=sharing

#### Criando um novo ec2

ansible-playbook -i inventories/app/hosts.ec2 --extra-vars "@inventories/app/group_vars/aws"   playbooks/create_ec2.yml -vvvvvv

#### Editando envs

ansible-vault edit --vault-password-file ~/.ansible_pass inventories/app/group_vars/aws

ansible-vault edit --vault-password-file ~/.ansible_pass inventories/app/group_vars/envs

ansible-vault edit --vault-password-file ~/.ansible_pass inventories/app/group_vars/nginx


#### Criando uma nova máquina ec2

ansible-playbook -i inventories/app/group_vars/hosts.ec2 --extra-vars "@inventories/app/group_vars/aws"  playbooks/create_ec2.yml -vvvvvv

#### variaveis aws

