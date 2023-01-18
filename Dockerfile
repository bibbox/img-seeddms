# seeddms installation
# 
# VERSION 1.2
#

FROM php:8.0-apache-bullseye
MAINTAINER Heimo Müller

ENV SEEDDMS_VERSION=6.0.19
#ENV LUCENE_VERSION=1.1.11
#ENV PREVIEW_VERSION=1.2.9

RUN apt-get update && apt-get install -y --force-yes apt-utils && apt-get install -my --force-yes wget gnupg

#RUN rm /etc/apt/preferences.d/no-debian-php && \
RUN    apt-get update && \
    apt-get -q -y --force-yes install \
        libpng-dev \
        imagemagick \
        libmcrypt-dev \
#        php-pear \
        poppler-utils \
        catdoc \
        curl \
#        php7.0-json \
#        php7.0-ldap \
#        php7.0-mbstring \
#        php7.0-mysql \
#        php7.0-sqlite3 \
#        php7.0-xml \
#        php7.0-xsl \
#        php7.0-zip \
#        php7.0-soap \
	zip \
	libzip-dev\
        default-mysql-client \
          default-libmysqlclient-dev
RUN docker-php-source extract
RUN docker-php-ext-configure zip
RUN docker-php-ext-install zip

RUN apt-get update && apt-get install -y libmagickwand-dev --no-install-recommends && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/src/php/ext/imagick; \
    curl -fsSL https://github.com/Imagick/imagick/archive/06116aa24b76edaf6b1693198f79e6c295eda8a9.tar.gz | tar xvz -C "/usr/src/php/ext/imagick" --strip 1; \
    docker-php-ext-install imagick;

RUN docker-php-ext-install gd mysqli pdo pdo_mysql

RUN a2enmod php && a2enmod rewrite && a2enmod dav && a2enmod dav_fs

RUN curl -kL https://sourceforge.net/projects/seeddms/files/seeddms-$SEEDDMS_VERSION/seeddms-quickstart-$SEEDDMS_VERSION.tar.gz/download > seeddms-quickstart-$SEEDDMS_VERSION.tar.gz  

RUN tar xvzf seeddms-quickstart-$SEEDDMS_VERSION.tar.gz --directory /var/www/ && \
rm seeddms*

COPY configs/create_tables-innodb.sql /var/www/seeddms51x/install/create_tables-innodb.sql
COPY configs/php.ini /usr/local/etc/php/
COPY configs/000-default.conf /etc/apache2/sites-available/
COPY configs/settings.xml /var/www/seeddms51x/conf/settings.xml

RUN chown -R www-data:www-data /var/www/seeddms60x/

RUN touch /var/www/seeddms60x/conf/ENABLE_INSTALL_TOOL
RUN service apache2 start
