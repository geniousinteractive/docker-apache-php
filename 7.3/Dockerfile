# Pull base image.
FROM php:7.3.12-apache

# Install tools
RUN apt-get clean && apt-get update && apt-get install --fix-missing wget apt-transport-https lsb-release ca-certificates gnupg2 -y
RUN apt-get clean && apt-get update && apt-get install --fix-missing -y \
  ruby-dev \
  rubygems \
  imagemagick \
  graphviz \
  memcached \
  libmemcached-tools \
  libmemcached-dev \
  libjpeg62-turbo-dev \
  libmcrypt-dev \
  libxml2-dev \
  libxslt1-dev \
  default-mysql-client \
  sudo \
  git \
  vim \
  zip \
  wget \
  htop \
  iputils-ping \
  dnsutils \
  telnet \
  linux-libc-dev \
  libyaml-dev \
  libpng-dev \
  zlib1g-dev \
  libzip-dev \
  libicu-dev \
  libpq-dev \
  bash-completion \
  libldap2-dev \
  libssl-dev \
  pv

# postgresql-client-9.5
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && echo "deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main" >> /etc/apt/sources.list && apt-get update && apt-get install -y postgresql-client-9.5

# Install memcached for PHP 7
RUN cd /tmp && git clone https://github.com/php-memcached-dev/php-memcached.git
RUN cd /tmp/php-memcached && sudo git checkout master && phpize && ./configure --disable-memcached-sasl && make && make install
RUN touch /usr/local/etc/php/conf.d/memcached.ini &&\
 echo "extension=/usr/local/lib/php/extensions/no-debug-non-zts-20180731/memcached.so" >> /usr/local/etc/php/conf.d/memcached.ini

RUN pecl install mcrypt-1.0.3 && \
  docker-php-ext-enable mcrypt

# Create new web user for apache and grant sudo without password
RUN useradd web -d /var/www -g www-data -s /bin/bash
RUN usermod -aG sudo web
RUN echo 'web ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Install YAML extension
RUN pecl install yaml-2.0.4 && echo "extension=yaml.so" > /usr/local/etc/php/conf.d/ext-yaml.ini

# Install APCu extension
RUN pecl install apcu

# Install sass and gem dependency
RUN apt-get install --fix-missing automake ruby2.5-dev libtool -y

# SASS and Compass installation
RUN gem install sass -v 3.7.3 ;\
  gem install compass;

# Installation node.js
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && apt-get update && apt-get install -y nodejs && npm install npm@latest -g

# Installation of LESS
RUN npm install -g less && npm install -g less-plugin-clean-css

# Installation of Grunt
RUN npm install -g grunt-cli

# Installation of Gulp
RUN npm install -g gulp

# Installation of Bower
RUN npm install -g bower

# Installation of Composer
RUN cd /usr/src && curl -sS http://getcomposer.org/installer | php
RUN cd /usr/src && mv composer.phar /usr/bin/composer

# Installation of drush 8 & 9
RUN git clone https://github.com/drush-ops/drush.git /usr/local/src/drush
RUN cp -r /usr/local/src/drush/ /usr/local/src/drush8/
RUN cp -r /usr/local/src/drush/ /usr/local/src/drush9/
RUN cd /usr/local/src/drush8 && git checkout -f 8.1.0
RUN cd /usr/local/src/drush8 && composer update && composer install
RUN ln -s /usr/local/src/drush8/drush /usr/bin/drush8
RUN cd /usr/local/src/drush9 && git checkout 9.1.0
RUN cd /usr/local/src/drush9 && composer update && composer install
RUN ln -s /usr/local/src/drush9/drush /usr/bin/drush9

# Installation of WP-CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp
RUN chmod +x /usr/local/bin/wp

# Intallation of drupal-check to see deprecated code.
RUN composer global require mglaman/drupal-check
RUN ln -s ~/.composer/vendor/bin/drupal-check /usr/local/bin

# Install xdebug. ver 2.9 pour php 7.3.1
RUN pecl install xdebug && \
  docker-php-ext-enable xdebug
RUN touch /usr/local/etc/php/conf.d/xdebug.ini &&\
  echo 'xdebug.remote_enable=1' >> /usr/local/etc/php/conf.d/xdebug.ini &&\
  echo 'xdebug.remote_autostart=0' >> /usr/local/etc/php/conf.d/xdebug.ini &&\
  echo 'xdebug.remote_connect_back=1' >> /usr/local/etc/php/conf.d/xdebug.ini &&\
  echo 'xdebug.remote_port=9000' >> /usr/local/etc/php/conf.d/xdebug.ini &&\
  echo 'xdebug.remote_log=/tmp/php7-xdebug.log' >> /usr/local/etc/php/conf.d/xdebug.ini &&\
  echo 'xdebug.idekey=PHPSTORM' >> /usr/local/etc/php/conf.d/xdebug.ini

# Apache2 config
COPY config/apache2.conf /etc/apache2
COPY core/envvars /etc/apache2
COPY core/other-vhosts-access-log.conf /etc/apache2/conf-enabled/
RUN rm /etc/apache2/sites-enabled/000-default.conf

#added for AH00111 Error 
ENV APACHE_RUN_USER  www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR   /var/log/apache2
ENV APACHE_PID_FILE  /var/run/apache2/apache2.pid
ENV APACHE_RUN_DIR   /var/run/apache2
ENV APACHE_LOCK_DIR  /var/lock/apache2
ENV APACHE_LOG_DIR   /var/log/apache2

# Install php extensions + added mysqli install
RUN docker-php-ext-install opcache pdo_mysql && docker-php-ext-install mysqli 
RUN docker-php-ext-configure gd --with-jpeg-dir=/usr/include/
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/
RUN docker-php-ext-install gd mbstring zip soap pdo_mysql mysqli xsl opcache calendar intl exif pgsql pdo_pgsql ftp bcmath ldap

# Custom Opcache
RUN ( \
  echo "opcache.memory_consumption=128"; \
  echo "opcache.interned_strings_buffer=8"; \
  echo "opcache.max_accelerated_files=20000"; \
  echo "opcache.revalidate_freq=5"; \
  echo "opcache.fast_shutdown=1"; \
  echo "opcache.enable_cli=1"; \
  ) >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

# Apache encore de la config
RUN rm -rf /var/www/html && \
  mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/html && \
  chown -R web:www-data /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/html
RUN a2enmod rewrite expires ssl && service apache2 restart

# Installation of PHP_CodeSniffer with Drupal coding standards.
# See https://www.drupal.org/node/1419988#coder-composer
RUN composer global require drupal/coder
RUN ln -s ~/.composer/vendor/bin/phpcs /usr/local/bin
RUN ln -s ~/.composer/vendor/bin/phpcbf /usr/local/bin
RUN phpcs --config-set installed_paths ~/.composer/vendor/drupal/coder/coder_sniffer

# install msmtp
RUN set -x \
    && DEBIAN_FRONTEND=noninteractive \
    && apt-get update && apt-get install -y --no-install-recommends msmtp && rm -r /var/lib/apt/lists/*
ADD core/msmtprc.conf /usr/local/etc/msmtprc
ADD core/php-smtp.ini /usr/local/etc/php/conf.d/php-smtp.ini

# Install Drupal Console for Drupal 8
RUN curl https://drupalconsole.com/installer -L -o drupal.phar && mv drupal.phar /usr/local/bin/drupal && chmod +x /usr/local/bin/drupal

# Our apache volume
VOLUME /var/www/html

# create directory for ssh keys
RUN mkdir /var/www/.ssh/
RUN chown -R web:www-data /var/www/

# Set timezone to Europe/Paris
RUN echo "Europe/Paris" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

# Expose 80,443 for apache + 9000 pour xdebug
EXPOSE 80 443 9000

# ADD BASHRC CONFIG
COPY config/bashrc /root/
RUN mv /root/bashrc /root/.bashrc

# Custom php.ini
COPY config/php.ini /usr/local/etc/php/

# Set and run a custom entrypoint
COPY core/docker-entrypoint.sh /
RUN chmod 777 /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

# CMD ["cat", "/etc/apache2/envvars"]
# CMD ["sed", "-n", "39p", "/etc/apache2/apache2.conf"]