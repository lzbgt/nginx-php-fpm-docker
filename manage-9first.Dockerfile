FROM nginx-php-fpm:latest
LABEL maintainer=Bruce.Lu
LABEL version=0.1
LABEL name=manage-9first
ENV user=lzbgt
ENV pass=pass
WORKDIR /
#COPY ./nginx.conf /usr/local/nginx/conf/nginx.conf
#COPY ./php.ini /usr/local/php/etc/
#COPY ./php-fpm.conf /usr/local/php/etc/
#COPY ./supervisord.conf /etc/supervisord.conf
RUN rm -fr /app && \
    git clone --depth 1 https://$user:$pass@gitee.com/xianzhi9first/communal.git && \
    git clone --depth 1 https://$user:$pass@gitee.com/xianzhi9first/vendor.git && \
    git clone --depth 1 https://$user:$pass@gitee.com/xianzhi9first/manage.9first.com.git app && \
    cp -fr /app/webroot/index.php.prod /app/webroot/index.php && \
    mkdir /app/runtime && \
    chown -R www:www /vendor /communal /app

