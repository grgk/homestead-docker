FROM php:7.2-fpm

LABEL maintainer="gfx@karpiak.pl"

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN apt-get update && apt-get install -y --no-install-recommends \
  libicu-dev \
  libxml2-dev \
  git \
  unzip \
  nano \
  beanstalkd \
  supervisor \
  cron \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN docker-php-ext-install opcache intl pdo_mysql mbstring bcmath

RUN export TERM=xterm
RUN echo 'alias ll="ls --color=auto -la"' >> ~/.bashrc \
    && echo 'alias phpunit="vendor/bin/phpunit"' >> ~/.bashrc \
    && echo 'alias artisan="php ./artisan"' >> ~/.bashrc

RUN yes | pecl install xdebug \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_connect_back=On" >> /usr/local/etc/php/conf.d/xdebug.ini

EXPOSE 11300/TCP

WORKDIR /opt/app/

COPY crontab /var/crontab
RUN crontab /var/crontab && touch /var/log/cron.log && cron

CMD /usr/bin/supervisord -c /etc/supervisor/supervisord.conf ; php-fpm