#### Empacotamento

Nosso objetivo, além de ter um artefato que pode ser propagado facilmente em
diversas máquinas, queremos criar um processo (um PID, em poucas palavras) para
ser gerenciado pelo sistema operacional. Com isso, ganhamos alguma facilidades,
como o gerenciamento automático de processos. Para mais informações:
https://systemd.io/

#### Estrutura:

Para gerar um pacote, devemos criar um diretório chamado `debian` na raiz do
projeto e criar quatro arquivos, esses arquivos são a estrutura mínima para
gerar um pacote, mas neste exemplo utilizando rails, teremos a seguinte
estrutura:

- control (obrigatório): Esse arquivo é utilizado pelo gerenciador de pacotes
  (apt-get, aptitude, etc). Ele possui essa cara:

```
Source: rails-ansible-presentation # Nome do pacote
Section: web # Essa sessão é como será organizado o pacote na lista de arquivos.  Para a lista completa de valores possíveis, ler:
Priority: optional # Esse é o level de importancia do pacote. Como é uma aplicação independênte, não precisamos nos preocupar com esse valor, mas caso queira mais detalhes de como escolher qual a prioridade, ler: https://www.debian.org/doc/debian-policy/ch-archive.html#priorities
Maintainer: Maintainer<maintainer_email@email.com> # Esse e-mail, é utilizado
pelo bugtracker para enviar e-mail caso algum bug seja encontrado. Como não será
um pacote publicado, pode ser mantido assim.
Build-Depends: debhelper (>= 12) # Esse é um valor importante. Esse campo, são os binários necessários na hora da construção da pacote. Essa opção está diretamente relacionada com o conteúdo do arquivo debian/rules
Homepage: <YOUR HOSTNAME HERE>

Package: rails-ansible-presentation
Architecture: any # A arquitetura que será gerado o pacote, valores possíveis: all e any. Caso o pacote sendo gerado, seja independente da arquitetura do SO, por exemplo, um shell script, pode ser utilizado a opção all.
Depends: ${shlibs:Depends}, ${misc:Depends} # Aqui está listado todos os pacotes
necessários para o funcionamento da aplicação. A linha: ${shlibs:Depends}, é
substituida com todas as dependências de bibliotecas necessárias para a
execução do pacote.
Description: rails_ansible_presentation
```

- changelog: São as mudanças que ocorreram no pacote. Precisamos somente ter o commit inicial, mas caso deseje utilizar em um pacote público, leia: https://www.debian.org/doc/debian-policy/ch-source.html#s-dpkgchangelog

Para gerar um novo changelog, execute os comandos (exemplo):


APP_VERSION=`echo "v0.0.01-app" | sed 's/v\([0-9.]\+\)\(-app\)\?/\1\2/'`
DEBEMAIL="Maintainer <maintainer_email@email.com>" dch --create --distribution unstable --package $APP_NAME --newversion $APP_VERSION "automatic build" --urgency "low"

Esse comando irá gerar o arquivo changelog, com o conteúdo:

```
PACKAGE (VERSION) unstable; urgency=low

  * 0.0.01-app automatic build

 -- Maintainer <maintainer_email@email.com>  Sun, 15 Oct 2023 19:53:57 +0000
```


- rules: Este arquivo, é o passo-a-passo de como o pacote será criado. Este
  arquivo é um executável e ele tem o mesmo formato de um Makefile. Abaixo, está
o rules desta aplicação:


```
export DH_VERBOSE = 1 # Durante o empacotamento, será mostrado o comando que
está sendo executado no momento.

%:
	dh $@ # Está linha é muito importante. Aqui está sendo chamado todos os
debhelpers "padrão" para serem executados.

override_dh_systemd_start:
	dh_systemd_start --no-start
override_dh_systemd_enable:
	dh_systemd_enable
override_dh_clean:
	rm -rf vendor/bundle/ .bundle/ public/assets
	dh_clean
override_dh_auto_build:
	bundle config build.nokogiri --use-system-libraries
	bundle install --deployment --without development test --path vendor/bundle
	RAILS_ENV=production bin/rake assets:precompile
override_dh_shlibdeps:
	dh_shlibdeps --dpkg-shlibdeps-params=--ignore-missing-info
```

A tag `override`, significa que o comando está sendo sobreescrito para fazer
outra atividade ou complementar a atividade daquele programa. Exemplo:

```
override_dh_clean: # A biblioteca dh_clean está sendo sobreescrita.
	rm -rf vendor/bundle/ .bundle/ public/assets # Quando o dh_clean for
executar, ele vai executar está linha primeiro
	dh_clean # após a remoção dos arquivos, a versão original vai ser executada.  Para mais informações sobre o dh_clean, ler: https://man7.org/linux/man-pages/man1/dh_clean.1.html
```


- compat: É a compatilhada com o debhelper. A versão deste arquivo, é a versão do debhelper que será utilizada. O recomendo é utilizar acima da versão 9, como pode ser visto aqui: https://www.debian.org/doc/manuals/maint-guide/dother.en.html#compat

- dirs: Este arquivo, irá criar diretórios que são essenciais, mas que não serão instalados normalmente. Esses diretórios irão aparecer durante a instalação do seu pacote.

- postisnt: Este script é executado quando o pacote é instalado, removido ou atualizado. Em especifico, esse script é executado ao fim de um destes status. Temos este script:

```
set -e

NAME="presentation"
APP_HOME=/var/www/rails-ansible-presentation
BUNDLER_VERSION="2.4.20"

folder_owner() {
  chown -R ${NAME}. ${APP_HOME}
}

install_bundler() {
  which bundle > /dev/null 2>&1 || gem install bundler -v ${BUNDLER_VERSION}
}

case "$1" in
  configure)
    install_bundler
    folder_owner
    ;;

  abort-upgrade|abort-remove|abort-deconfigure)
    ;;

  *)
    echo "postinst called with unknown argument \`$1'" >&2
    exit 1
    ;;
esac

exit 0
```

Após a instalação do pacote no diretório /var/www/<app_name> verificamos se o
bundler está instalado e alteramos a aplicação para ser executada com um usuário
comum. Lembrando que a instalação do dpkg, apt-get, aptitude, etc, ocorrem com o
usuário `root`. Aqui garantimos que não iremos usar um superusuário para
executar uma atividade.

obs: Repare na variável NAME, mais para frente iremos comentar sobre o service e este valor irá aparecer novamente.

- preinst: Este script é executado quando o pacote é instalado, removido ou atualizado. Neste arquivo em específico, o script é executado antes da instalação do pacote.

```
set -e

NAME="presentation"
APP_HOME=/var/www/rails-ansible-presentation

create_user() {
  getent passwd ${NAME} > /dev/null 2>&1 || adduser --home ${APP_HOME} --system ${NAME} --group
}

case "$1" in
    install|upgrade)
      create_user
    ;;

    abort-upgrade)
    ;;

    *)
        echo "preinst called with unknown argument \`$1'" >&2
        exit 1
    ;;
esac

exit 0
```

Antes da instalação do pacote, iremos criar um usuário comum que será
responsável por executar este programa. Repare na variável NAME, mais para
frente iremos comentar sobre o service e este valor irá aparecer novamente.


- Service: É um unit file, em poucas palavras. Este arquivo representa como o
  systemd irá gerenciar essa aplicação. Ou seja, qual o usuário vai executar o
programa, quais as variáveis de ambiente serão necessárias. Qual o comando para
execução do serviço, quanto tempo aguardar para reiniciar em caso de panico,
etc.

```
[Unit]
Description=Rails_ansible_presentation web app
After=network.target # O serviço será executado após o serviço da rede subir. Mais detalhes: https://www.freedesktop.org/wiki/Software/systemd/NetworkTarget/

[Service]
Type=simple # O tipo de serviço que será executado, estamos utilizando o padrão simple, com isso, garantimos que o serviço está executando quando o o processo principal (ExecStart) estiver executando com sucesso. Para mais opções: https://www.freedesktop.org/software/systemd/man/systemd.service.html#Type=
TimeoutSec=120 # O tempo que o serviço pode levar para iniciar em segundos. Caso não inicie em 120 segundos, será dado shut down e feito outra retentativa.
RestartSec=5 # Após o shut down de um serviço, o tempo que irá levar para tentar executar novamente.
Restart=always # Sempre tentar reiniciar caso o serviço falhe. Mais opções: https://www.freedesktop.org/software/systemd/man/systemd.service.html#Restart=
User=presentation # O usuário que irá executar o serviço. Esse usuário foi criado no preinst e o projeto foi delegado para ele no postinst
Group=presentation # o grupo do usuário que irá executar o serviço. Esse grupo foi criado no preinst  e o projeto foi delegado para ele no postinst
PermissionsStartOnly=true # O usuário e grupo somente serão aplicados no ExecStart. Esta sintaxe está descontinuada, leia mais: https://github.com/systemd/systemd/blob/60b45a80c1f98bad000bd902d97ecf6c4e3fc315/NEWS#L2434. Como a forma nova não é muito comunicativa, decidi deixar no formato anterior que ainda possui suporte
StandardOutput=syslog # As logs do serviço serão inseridas no syslog (/var/log/syslog)
StandardError=syslog # As logs do serviço de erro serão inseridas no syslog (/var/log/syslog)
SyslogIdentifier=presentation # A tag que irá identificar no syslog o serviço

EnvironmentFile=/etc/default/rails-ansible-presentation # Arquivo onde estão as variáveis de ambiente necessárias para execução do serviço, caso existam.
WorkingDirectory=/var/www/rails-ansible-presentation # Diretório ou raíz do serviço
ExecStart=/usr/local/bin/bundle exec puma -C config/puma.rb # O comando que o systemd irá executar para inicializar o serviço

[Install]
WantedBy=multi-user.target # É um determinado runlevel do systemd. Será criado um link no diretório: /etc/systemd/system/multi-user.target.wants/rails-ansible-presentation.service. Quando o multi-user.target foi inicializado (por exemplo, no login) esse serviço será inicializado também

# vi: set ft=systemd :
```
