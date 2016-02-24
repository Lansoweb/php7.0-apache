FROM php:7.0-apache

MAINTAINER Leandro Silva <leandro@leandrosilva.info>

COPY bin/* /usr/local/bin/

# Include composer
RUN apt-install git zlib1g-dev && \
    docker-php-ext-install zip

ENV COMPOSER_HOME /root/composer
ENV PATH vendor/bin:$COMPOSER_HOME/vendor/bin:$PATH

RUN curl -sS https://getcomposer.org/installer | php -- \
      --install-dir=/usr/local/bin \
      --filename=composer

VOLUME /root/composer/cache

# Install useful extensions
RUN apt-install \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libpq-dev \
        zlib1g-dev \
        libicu-dev \
        vim \
	libxml2-dev \
	libaio1

RUN docker-php-ext-install \
        opcache \
	ctype \
	dom \
	fileinfo \
	phar \
	simplexml \
	zip \
	json \
        intl \
	pcntl \
        mbstring \
        mcrypt \
        mysqli \
	pdo \
        pdo_mysql \
        pdo_pgsql \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd

RUN docker-php-pecl-install channel://pecl.php.net/apcu-4.0.7

RUN printf '[Date]\ndate.timezone=UTC' > /usr/local/etc/php/conf.d/timezone.ini \
	&& echo "phar.readonly = off" > /usr/local/etc/php/conf.d/phar.ini

# Setup the Xdebug version to install
ENV XDEBUG_VERSION 2.4.0rc4
ENV XDEBUG_MD5 0ff361aa7bc8098ff7dd4c2ea13e7773

# Install Xdebug
RUN set -x \
	&& curl -SL "http://www.xdebug.org/files/xdebug-$XDEBUG_VERSION.tgz" -o xdebug.tgz \
	&& echo $XDEBUG_MD5 xdebug.tgz | md5sum -c - \
	&& mkdir -p /usr/src/xdebug \
	&& tar -xf xdebug.tgz -C /usr/src/xdebug --strip-components=1 \
	&& rm xdebug.* \
	&& cd /usr/src/xdebug \
	&& phpize \
	&& ./configure \
	&& make -j"$(nproc)" \
	&& make install \
	&& make clean

RUN a2enmod rewrite

