# ベースイメージをwordpress:latestに設定
FROM wordpress:latest

# PHP設定ファイルを追加
COPY ./php.ini /usr/local/etc/php/

# 環境変数を設定
ENV WORDPRESS_CONFIG_EXTRA="define('FS_METHOD', 'direct');"

RUN echo "define('WPLANG', 'ja');" >> /usr/src/wordpress/wp-config-docker.php
RUN echo "define('WPLANG', 'ja');" >> /usr/src/wordpress/wp-config-sample.php

RUN mkdir /var/www/html/wp-content/languages
RUN chown -R www-data:www-data /var/www/html/wp-content/languages