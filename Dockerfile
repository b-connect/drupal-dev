FROM php:7.0.7

# Install all packages
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        curl \
        redis-server \
        libz-dev \
        libpq-dev \
        graphviz \
        supervisor \
        libpng12-dev \
        apt-utils \
        vim-tiny \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-install -j$(nproc) mcrypt \
    && docker-php-ext-install -j$(nproc) pdo_mysql \
    && docker-php-ext-install -j$(nproc) zip \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install -j$(nproc) xdebug \
    && docker-php-ext-install bcmath opcache

RUN apt-get clean

# get from https://github.com/docker-library/drupal/blob/master/8.1/apache/Dockerfile
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Copy default php.ini
COPY docker-config/php.ini /usr/local/etc/php/

# Copy binaries for drupal console and drush
COPY docker-config/drupal /usr/bin/drupal
COPY docker-config/drush /usr/bin/drush

# init drush and drupal console and make them executable
RUN chmod +x /usr/bin/drupal
RUN drupal init -y
RUN chmod +x /usr/bin/drush
RUN drush init -y
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Install NODE

RUN mkdir /drone

RUN cd /drone && \
	wget https://phar.phpunit.de/phploc.phar && \
    chmod +x phploc.phar && \
    mv phploc.phar /usr/local/bin/phploc && \
    wget http://static.pdepend.org/php/latest/pdepend.phar && \
	chmod +x pdepend.phar && \
	mv pdepend.phar /usr/local/bin/pdepend && \
    wget http://static.phpmd.org/php/latest/phpmd.phar && \
	chmod +x phpmd.phar && \
	mv phpmd.phar /usr/local/bin/phpmd && \
    wget https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar && \
	chmod +x phpcs.phar && \
	mv phpcs.phar /usr/local/bin/phpcs && \
    wget https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar && \
	chmod +x phpcbf.phar && \
	mv phpcbf.phar /usr/local/bin/phpcbf && \
    wget https://phar.phpunit.de/phpcpd.phar && \
	chmod +x phpcpd.phar && \
	mv phpcpd.phar /usr/local/bin/phpcpd && \
    wget https://phar.phpunit.de/phpdcd.phar && \
	chmod +x phpdcd.phar && \
	mv phpdcd.phar /usr/local/bin/phpdcd && \
	wget https://github.com/Halleck45/PhpMetrics/raw/master/build/phpmetrics.phar && \
	chmod +x phpmetrics.phar && \
	mv phpmetrics.phar /usr/local/bin/phpmetrics && \
	wget http://get.sensiolabs.org/php-cs-fixer.phar && \
	chmod +x php-cs-fixer.phar && \
	mv php-cs-fixer.phar /usr/local/bin/php-cs-fixer

VOLUME /drone
