# Version 1.0.3

FROM jeromeklam/u20
MAINTAINER Jérôme KLAM, "jeromeklam@free.fr"

ENV DEBIAN_FRONTEND noninteractive
ENV PHP_VER 7.3

## Installation de PHP 7
RUN apt-get update && apt-get install -y libzmq3-dev
RUN apt-get update && LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
RUN apt-get update && apt-get install -y php${PHP_VER} php${PHP_VER}-cli php${PHP_VER}-common
RUN apt-get update && apt-get install -y php${PHP_VER}-mbstring php${PHP_VER}-mysql php${PHP_VER}-xml php${PHP_VER}-soap
RUN apt-get update && apt-get install -y php${PHP_VER}-dev php${PHP_VER}-tidy php${PHP_VER}-zip php${PHP_VER}-memcached
RUN apt-get update && apt-get install -y php${PHP_VER}-curl php-ldap php${PHP_VER}-gd php${PHP_VER}-intl php${PHP_VER}-gmp php${PHP_VER}-zmq
RUN apt-get update && apt-get install -y php${PHP_VER}-xdebug php${PHP_VER}-redis php${PHP_VER}-fpm 

# Supervisor
COPY ./docker/supervisord.conf /etc/supervisor/conf.d/php-fpm.conf

# Standardize PHP executable location
RUN rm -f /etc/alternatives/php && ln -s /usr/bin/php${PHP_VER} /etc/alternatives/php
RUN rm -f /etc/alternatives/phar.phar && ln -s /usr/bin/phar.phar${PHP_VER} /etc/alternatives/phar.phar
RUN rm -f /etc/alternatives/phpize && ln -s /usr/bin/phpize${PHP_VER} /etc/alternatives/phpize
RUN rm -f /usr/sbin/php-fpm && ln -s /usr/sbin/php-fpm${PHP_VER} /usr/sbin/php-fpm
RUN mkdir -p /run/php

# PHP config
COPY docker/php.ini /etc/php/${PHP_VER}/fpm/
COPY docker/www.conf /etc/php/${PHP_VER}/fpm/pool.d/

## Installation de composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/bin/composer

# unoconv 
RUN apt-get update && apt-get install -y unoconv
RUn chmod 777 /var/www

# Volumes & ports
EXPOSE 9000
EXPOSE 9080
EXPOSE 8080

# ssh key
RUN mkdir -p /user.ssh
COPY docker/makessh.sh /usr/bin/makessh.sh
RUN chmod 775 /usr/bin/makessh.sh

RUN mkdir -p /tmp/docker
VOLUME ["/var/www/html", "/user.ssh"]
WORKDIR /var/www/html

ADD docker/start.sh /usr/bin/
RUN chmod 775 /usr/bin/start.sh

CMD ["/usr/bin/start.sh"]