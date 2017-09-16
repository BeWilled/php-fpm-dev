FROM php:7.1.9-fpm

RUN php -r "readfile('https://s3.amazonaws.com/files.drush.org/drush.phar');" > drush
RUN php drush core-status
RUN chmod +x drush
RUN mv drush /usr/local/bin
RUN drush init --add-path -y


RUN echo "deb http://ftp.uk.debian.org/debian jessie-backports main" >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y zip git mysql-client pkg-config libssl-dev locate vim libzip-dev ffmpeg wget bc axel nodejs npm

RUN drush dl drush_remake-7.x


# Install GD
RUN apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng12-dev
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install gd && docker-php-ext-install pdo && docker-php-ext-install pdo_mysql && docker-php-ext-install opcache

RUN yes | pecl install xdebug \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo  xdebug.idekey = \"PHPSTORM\" >> /usr/local/etc/php/conf.d/xdebug.ini

RUN yes | pecl install zip  \
  && echo "extension=$(find /usr/local/lib/php/extensions/ -name zip.so)" > /usr/local/etc/php/conf.d/zip.ini

RUN pear install XML_RPC2

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
