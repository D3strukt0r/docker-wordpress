#!/bin/bash

set -eux

# Setup some recommended variables for Wordpress
{
    echo 'error_reporting = E_ERROR | E_WARNING | E_PARSE | E_CORE_ERROR | E_CORE_WARNING | E_COMPILE_ERROR | E_COMPILE_WARNING | E_RECOVERABLE_ERROR'
    echo 'display_errors = Off'
    echo 'display_startup_errors = Off'
    echo 'log_errors = On'
    echo 'error_log = /dev/stderr'
    echo 'log_errors_max_len = 1024'
    echo 'ignore_repeated_errors = On'
    echo 'ignore_repeated_source = Off'
    echo 'html_errors = Off'
} > "$PHP_INI_DIR"/conf.d/error-logging.ini

# Download Wordpress
if [[ ! -f "/build/wordpress.tar.gz" ]]; then
    wp --allow-root core download
    
    # Delete download cache
    rm -r /home/www-data
else
    # In case you downloaded and put the wordpress file under /build/php/wordpress.tar.gz manually
    tar --strip-components=1 -xzf /build/wordpress.tar.gz
fi

# Fix permission
chown www-data:www-data -R .
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;

# Delete standard stuff
rm -r ./wp-content/plugins/akismet \
      ./wp-content/plugins/hello.php \
      ./wp-content/themes/twentyseventeen \
      ./wp-content/themes/twentynineteen \
      ./wp-content/themes/twentytwenty \
      ./wp-config-sample.php

# Redownload latest theme
curl -fsSL -o /tmp/twentytwenty.zip https://downloads.wordpress.org/theme/twentytwenty.1.3.zip
unzip -q /tmp/twentytwenty.zip -d ./wp-content/themes/
rm /tmp/twentytwenty.zip

# Move wp-content somewhere else to act as "skeleton"
mv ./wp-content /tmp
