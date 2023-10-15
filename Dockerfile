FROM ubuntu:22.04

ENV APP_PATH /var/www/rails-ansible-presentation
ENV BUNDLE_VERSION 2.4.20

RUN apt-get update -qq
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
RUN apt-get install -y --no-install-recommends locales autotools-dev libyaml-dev pkg-config gnupg autoconf openssh-client dh-make vim ruby ruby-dev make musl-dev software-properties-common python3-distutils python3-apt python3-pip devscripts
RUN add-apt-repository --yes --update ppa:ansible/ansible && apt-get install -y ansible
RUN pip install boto3
RUN gem install bundler -v $BUNDLE_VERSION
RUN bundle install

RUN mkdir -p $APP_PATH
WORKDIR $APP_PATH

ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock

ADD . $APP_PATH
