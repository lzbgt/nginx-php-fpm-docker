FROM nginx-php-fpm
LABEL maintainer=Bruce.Lu
LABEL version=0.1
LABEL name=manage-9first
ENV user=lzbgt
ENV pass=pass
WORKDIR /
RUN echo "machine gitee.com lzbgt password " > ~/.netrc
RUN rm -fr /app && \
    git clone --depth 1 https://$user:$pass@gitee.com/xianzhi9first/communal.git && \
    git clone --depth 1 https://$user:$pass@gitee.com/xianzhi9first/vendor.git && \
    git clone --depth 1 https://$user:$pass@gitee.com/xianzhi9first/manage.9first.com.git app && \
    cp -fr /app/webroot/index.php.prod /app/webroot/index.php

