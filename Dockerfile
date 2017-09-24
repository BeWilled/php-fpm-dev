FROM php:7.1.9-fpm

RUN php -r "readfile('https://s3.amazonaws.com/files.drush.org/drush.phar');" > drush
RUN php drush core-status
RUN chmod +x drush
RUN mv drush /usr/local/bin
RUN drush init --add-path -y


RUN echo "deb http://ftp.uk.debian.org/debian jessie-backports main" >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y zip git mysql-client pkg-config libssl-dev locate vim libzip-dev ffmpeg wget bc axel nodejs npm aria2 nginx

RUN drush dl drush_remake-7.x


# Install GD
RUN apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng12-dev
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install gd && docker-php-ext-install pdo && docker-php-ext-install pdo_mysql && docker-php-ext-install opcache &&  docker-php-ext-configure opcache

RUN yes | pecl install xdebug \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo  xdebug.idekey = \"PHPSTORM\" >> /usr/local/etc/php/conf.d/xdebug.ini

RUN yes | pecl install zip  \
  && echo "extension=$(find /usr/local/lib/php/extensions/ -name zip.so)" > /usr/local/etc/php/conf.d/zip.ini

RUN pear install XML_RPC2

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php --install-dir=/usr/local/bin/ --filename=composer
RUN php -r "unlink('composer-setup.php');"


# forward request and error logs to docker log collector
# RUN ln -sf /dev/stdout /var/log/nginx/access.log \
# 	&& ln -sf /dev/stderr /var/log/nginx/error.log

#Start nginx and fpm.

# RUN echo "nginx -g \"daemon off;\" &" >> /start.sh
# RUN echo "php-fpm" >> /start.sh
# RUN chmod +x /start.sh
# CMD ["/start.sh"]

CMD ["php-fpm"]
