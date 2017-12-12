FROM nginx-php-fpm
LABEL maintainer=Bruce.Lu
LABEL version=0.1
LABEL name=manage-9first
WORKDIR /
RUN rm -fr /app && \
    git pull --depth 1 https://gitee.com/xianzhi9first/communal.git && \
    git pull --depth 1 https://gitee.com/xianzhi9first/vendor.git && \
    git pull --depth 1 https://gitee.com/xianzhi9first/manage.9first.com.git app && \
    cp -fr /app/webroot/index.php.prod /app/webroot/index.php

