Uma opção para deployar a aplicação é usando a biblioteca [act](https://github.com/nektos/act). Com ela conseguimos simular o github actions localmente.
Após a instalação, crie um arquivo na raíz do projeto:

`cd /var/www/rails-ansible-presentation && touch my.pass`

Como conteúdo, adicione as seguintes variáveis, seguindo o formato de exemplo:

```
SSH_KEY="-----BEGIN RSA PRIVATE KEY-----
....
-----END RSA PRIVATE KEY-----"
ANSIBLE_PASS=<SUA_ANSIBLE_PASS>
SECRET_KEY_BASE=<SECRET_KEY_DO_RAILS>
```

observação: A `SSH_KEY` é a pem que você criou no dashboard do ec2 na aws.

Siga todos os passos como detalhados no arquivo docs/doc.md
Execute o comando:

`./bin/act -j deploy_act --secret-file my.pass`
