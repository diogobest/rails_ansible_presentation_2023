Passos:

0. Caso decida utilizar os arquivos de exemplo, utilize a senha: `R2TNAuWpMuWPjouyLPJL`
1. Criar a senha no arquivo ~/.ansible_pass, algo como:

echo "<SENHA>" > .ansible_pass

2. Crie um group_var para a aws:

`ansible-vault create --vault-password-file ~/.ansible_pass ansible/inventories/app/group_vars/aws`

Com as seguintes variáveis:

```
aws_tag_name: "presentation ec2" # Nome da identificação da máquina no ec2
aws_region: "us-east-1" # Região que o ec2 será criado
aws_key_name: "test-letz" # O nome da chave de acesso via ssh em uma instancia
do ec2. Caso não tenha, crie no dashboard da aws.
aws_instance_type: "t2.micro" # A configuração da máquina
aws_image: "ami-053b0d53c279acc90" # O código da imagem que será utilizada, neste
caso é um ubuntu 22.04
aws_count: 1 # A quantidade de máquinas ec2
aws_security_group: "launch-wizard-1" # Nome da security_group, recomendo que
seja criado antes, por causa das configurações de inbound e outbound da máquina.
Nesse tutorial, não irei cobrir isso
aws_vpc_subnet: "subnet-04efff7283b1a3648" # O nome da subnet
aws_access_key: "<ACCESS_KEY>" # A sua access_key
aws_secret_access_key: "<SECRET_KEY>" # A sua secret_key
```

2.1. Caso deseje editar o arquivo de exemplo, utilize o comando:

`ansible-vault edit --vault-password-file ~/.ansible_pass ansible/inventories/app/group_vars/aws`

3. Fazer a criação do EC2

cd /var/www/rails-ansible-presentation/ansible && ansible-playbook -i inventories/app/hosts.ec2 --extra-vars "@inventories/app/group_vars/aws"   playbooks/create_ec2.yml -vvvvvv

4. Adicione o nome do host(public ip dns) criado no arquivo: /var/www/rails-ansible-presentation/ansible/inventories/app/group_vars/hosts.ec2, abaixo da tag `[web]`
5. Adicione uma entrada DNS do tipo A no seu domínio.
6. Crie o arquivo no inventário para configuração do nginx:

`ansible-vault create --vault-password-file ~/.ansible_pass ansible/inventories/app/group_vars/nginx`

Adicione os seguintes dados:

```
letsencrypt_dir: "/etc/letsencrypt"
domain: "<YOUR_WEB_DOMAIN>"
certbot_service_admin_email: "email@email.com"
certbot_service_name: "apresentacao rails"
certbot_ssl_dir: "/etc/letsencrypt/live"
assets_path: "/var/www/rails-ansible-presentation/public"
app_name: "rails-ansible-presentation"
alternative_domains: ''

```

6.1. Caso seja necessário editar qualquer informação do nginx, utilize o comando:

`ansible-vault edit --vault-password-file ~/.ansible_pass ansible/inventories/app/group_vars/nginx`

7. Crie o arquivo no inventário para configuração do rails:

`ansible-vault create --vault-password-file ~/.ansible_pass ansible/inventories/app/group_vars/envs`

Adicione os seguintes dados:

```
rails_env: "production" # A env que você quer que o rails execute
secret_key: "<SECRET_KEY>" # A secret key
```

7.1. Caso seja necessário editar qualquer informação do nginx, utilize o comando:

`ansible-vault edit --vault-password-file ~/.ansible_pass ansible/inventories/app/group_vars/envs`

8. Adicione no seu repositório todos os arquivos acima.
