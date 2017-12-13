FROM centos:latest
LABEL maintainer=Bruce.Lu
LABEL version=0.1
LABEL description=PHP-image
LABEL name=nginx-php-fpm

# php build
COPY ./CentOS7-Base.repo /etc/yum.repos.d/CentOS-Base.repo
RUN yum update -y && \
    yum -y install git libtool file zip unzip wget gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers pcre-devel libmcrypt libmcrypt-devel libiconv && \
    cd /usr/local/src && \
    wget http://yum.dfwsgroup.com/source/php/freetds-0.95.95.tar.gz && \
    tar xvf freetds-0.95.95.tar.gz && \
    cd freetds-0.95.95 && \
    ./configure --prefix=/usr/local/freetds --with-tdsver=7.3 --enable-msdblib && \
    make -j4 && make install && \
    libtool --finish /usr/local/freetds/lib && \
    useradd www && \
    cd /usr/local/src && \
    wget http://yum.dfwsgroup.com/source/php/mhash-0.9.9.9.tar.gz && \
    tar -zxvf mhash-0.9.9.9.tar.gz && \
    cd mhash-0.9.9.9 && \
    ./configure --prefix=/usr/local/mhash && \
    make -j4 && make install && \
    cd /usr/local/src && \
    wget http://yum.dfwsgroup.com/source/php/libiconv-1.14.tar.gz && \
    tar -zxvf libiconv-1.14.tar.gz  && \
    cd libiconv-1.14 && \
    sed -i '698s/^.*$/#if defined(__GLIBC__) \&\& !defined(__UCLIBC__) \&\& !__GLIBC_PREREQ(2, 16)\n_GL_WARN_ON_USE (gets, "gets is a security hole - use fgets instead");\n#endif/' /usr/local/src/libiconv-1.14/srclib/stdio.in.h && \
    ./configure --prefix=/usr/local/libiconv && \
    make -j4 && make install && \
    libtool --finish /usr/local/libiconv/lib && \
    cd /usr/local/src && \
    wget http://yum.dfwsgroup.com/source/php/libmcrypt-2.5.8.tar.gz && \
    tar -zxvf  libmcrypt-2.5.8.tar.gz  && \
    cd libmcrypt-2.5.8 && \
    ./configure  --prefix=/usr/local/libmcrypt && \
    make -j4 && make install && \
    libtool --finish /usr/local/libmcrypt/lib && \
    cd libltdl && \
    ./configure --with-gmetad --enable-gexec --enable-ltdl-install --prefix=/usr/local/libltdl && \
    make -j4 && make install  && \
    libtool --finish /usr/local/libltdl/lib && \
    cp -frp /usr/lib64/libldap* /usr/lib/ && \
    cp -frp /usr/lib64/liblber* /usr/lib/ && \
    cd /usr/local/src && \
    wget http://yum.dfwsgroup.com/source/php/php-5.6.15.tar.gz && \
    tar xvf php-5.6.15.tar.gz && \
    cd php-5.6.15 && \
    ./configure \
        --prefix=/usr/local/php \
        --without-pear \
        --with-mysql \
        --with-mysqli \
        --enable-pdo \
        --enable-fpm \
        --with-freetype-dir=/usr/lib64 \
        --with-iconv-dir \
        --with-jpeg-dir=/usr/lib64 \
        --with-png-dir \
        --with-zlib \
        --with-libxml-dir \
        --enable-xml \
        --enable-bcmath \
        --enable-shmop \
        --enable-sysvsem \
        --enable-inline-optimization \
        --with-curl \
        --enable-mbregex \
        --enable-mbstring \
        --with-mcrypt=/usr/local/libmcrypt \
        --with-gd \
        --enable-gd-native-ttf \
        --with-openssl \
        --with-mhash \
        --enable-pcntl \
        --enable-sockets \
        --with-ldap=/usr \
        --with-ldap-sasl \
        --with-xmlrpc \
        --enable-zip \
        --enable-soap \
        --with-pdo-mysql \
        --with-fpm-user=www \
        --with-fpm-group=www \
        --with-gettext \
        --enable-ftp \
        --enable-opcache \
        --enable-calendar \
        --enable-exif \
        --with-bz2 \
        --with-config-file-path=/usr/local/php/etc \
        --with-mssql=/usr/local/freetds \
        --with-iconv=/usr/local/libiconv && \
    make -j4 ZEND_EXTRA_LIBS='-liconv' && make install
RUN cd /usr/local/php/etc && \
    cp php-fpm.conf.default php-fpm.conf && \
    cp /usr/local/src/php-5.6.15/php.ini-production php.ini && \
    mkdir -p /home/logs/php/ && \
	cd /usr/local/src && \
	wget http://yum.dfwsgroup.com/source/libmemcached-1.0.18.tar.gz && \
	tar xvf libmemcached-1.0.18.tar.gz && \
	cd libmemcached-1.0.18 && \
	./configure -prefix=/usr/local/libmemcached -with-memcached && \
	make -j4 && make install && \
	cd /usr/local/src && \
	wget http://yum.dfwsgroup.com/source/memcached-2.2.0.tgz && \
	tar xvf memcached-2.2.0.tgz && \
	cd memcached-2.2.0 && \
	/usr/local/php/bin/phpize && \
	./configure --with-php-config=/usr/local/php/bin/php-config --with-libmemcached-dir=/usr/local/libmemcached --enable-memcache  --disable-memcached-sasl && \
	make -j4 && make install && \
    cd /usr/local/src/php-5.6.15/ext/pdo_dblib && \
    /usr/local/php/bin/phpize && \
    ./configure --with-php-config=/usr/local/php/bin/php-config --with-pdo-dblib=/usr/local/freetds/ && \
    make -j4 && make install && \
	cd /usr/local/src && \
	wget http://pecl.php.net/get/memcache-3.0.8.tgz && \
	tar -zxvf memcache-3.0.8.tgz && \
	cd memcache-3.0.8 && \
	/usr/local/php/bin/phpize && \
	./configure --with-php-config=/usr/local/php/bin/php-config && \
	make -j4 && make install && \
    cd /usr/local/src && \
	wget http://yum.dfwsgroup.com/source/scws-1.2.2.tar.bz2 && \
	wget http://yum.dfwsgroup.com/source/scws-dict-chs-utf8.tar.bz2 && \
	wget http://www.xunsearch.com/scws/down/scws-dict-chs-gbk.tar.bz2 && \
	tar xjvf scws-1.2.2.tar.bz2 && \
	cd scws-1.2.2 && \
	./configure --prefix=/usr/local/scws && \
	make -j4 && make install && \
    cd /usr/local/src && \
	tar xjvf scws-dict-chs-utf8.tar.bz2 -C /usr/local/scws/etc && \
	tar xjvf scws-dict-chs-gbk.tar.bz2 -C /usr/local/scws/etc && \
    cd scws-1.2.2/phpext/ && \
	/usr/local/php/bin/phpize && \
	./configure --with-php-config=/usr/local/php/bin/php-config --with-scws=/usr/local/scws && \
	make -j4 && make install

# nginx build
RUN yum install -y gd-devel gd && \
    cd /usr/local/src && \
    wget http://yum.dfwsgroup.com/source/nginx/libfastcommon-master.zip && \
    unzip libfastcommon-master.zip && \
    cd libfastcommon-master && \
    ./make.sh && \
    ./make.sh install && \
    cd /usr/local/src && \
    wget http://yum.dfwsgroup.com/source/nginx/libevent-2.0.22-stable.tar.gz && \
    tar -zvxf libevent-2.0.22-stable.tar.gz && \
    cd libevent-2.0.22-stable && \
    ./configure --prefix=/usr/local/libevent && \
    make && make install && \
    cd /usr/local/src && \
    wget http://yum.dfwsgroup.com/source/nginx/FastDFS_v5.08.tar.gz && \
    tar -zvxf FastDFS_v5.08.tar.gz && \
    cd FastDFS && \
    ./make.sh C_INCLUDE_PATH=/usr/local/libevent/include LIBRARY_PATH=/usr/local/libevent/lib && \
    ./make.sh install && \
    cd /usr/local/src && \
    echo "/usr/local/lib" >>  /etc/ld.so.conf && \
    echo "/usr/local/lib64" >>  /etc/ld.so.conf && \
    /sbin/ldconfig && \
    mkdir -p /home/log/nginx/ && \
    mkdir -p /var/nginx_temp/{nginx_client,nginx_proxy,nginx_fastcgi && \
    ln -s /usr/include/fastdfs/*.h /usr/include && \
    ln -s /usr/include/fastcommon/*.h /usr/include && \
    cd /usr/local/src && \
    wget  http://yum.dfwsgroup.com/source/nginx/zlib-1.2.8.tar.gz && \
    tar xvzf zlib-1.2.8.tar.gz && \
    cd zlib-1.2.8 && \
    ./configure --prefix=/usr/local && \
    make && make install && \
    cd /usr/local/src && \
    wget http://sourceforge.net/projects/pcre/files/pcre/8.36/pcre-8.36.tar.gz  && \
    tar xvzf pcre-8.36.tar.gz  && \
    cd pcre-8.36 && \
    ./configure --prefix=/usr/local && \
    make && make install && \
    cd /usr/local/src && \
    wget  http://yum.dfwsgroup.com/source/nginx/openssl-1.0.1m.tar.gz && \
    tar xvzf openssl-1.0.1m.tar.gz && \
    cd openssl-1.0.1m && \
    ./config shared --prefix=/usr/local && \
    make -j1 && make install && \
    cd /usr/local/src && \
    wget  http://yum.dfwsgroup.com/source/nginx/fastdfs-nginx-module_v1.16.tar.gz && \
    tar xvzf fastdfs-nginx-module_v1.16.tar.gz && \
    cp fastdfs-nginx-module/src/mod_fastdfs.conf /etc/fdfs && \
    cd /usr/local/src && \
    wget http://yum.dfwsgroup.com/source/nginx/LuaJIT-2.0.2.tar.gz && \
    tar -xzvf LuaJIT-2.0.2.tar.gz && \
    cd LuaJIT-2.0.2 && \
    make && \
    make install && \
    cd /usr/local/src && \
    wget http://yum.dfwsgroup.com/source/nginx/nginx-rtmp-module-1.1.4.tar.gz && \
    tar -zxvf nginx-rtmp-module-1.1.4.tar.gz && \
    cd /usr/local/src && \
    wget http://yum.dfwsgroup.com/source/nginx/ngx_http_substitutions_filter_module-master.zip && \
    unzip ngx_http_substitutions_filter_module-master.zip && \
    cd /usr/local/src && \
    wget http://yum.dfwsgroup.com/source/nginx/nginx-http-module.zip && \
    unzip nginx-http-module.zip && \
    wget http://yum.dfwsgroup.com/source/nginx/lua-nginx-module-master.zip && \
    unzip lua-nginx-module-master.zip && \
    wget http://yum.dfwsgroup.com/source/nginx/nginx_lua_module-master.zip && \
    unzip nginx_lua_module-master.zip && \
    wget http://yum.dfwsgroup.com/source/nginx/nginx_mod_h264_streaming-2.2.7.tar.gz && \
    tar -zxvf nginx_mod_h264_streaming-2.2.7.tar.gz
RUN cd /usr/local/src/ && \
    wget http://tengine.taobao.org/download/tengine-2.1.2.tar.gz && \
    tar -zxvf tengine-2.1.2.tar.gz  && \
    cd /usr/local/src/tengine-2.1.2 && \
    export LUAJIT_LIB=/usr/local/lib && \
    export LUAJIT_INC=/usr/local/include/luajit-2.0 && \
    export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH && \
    ./configure --prefix=/usr/local/nginx \
    --lock-path=/var/lock/nginx.lock \
    --pid-path=/var/run/nginx.pid \
    --error-log-path=/home/log/nginx/error.log \
    --http-log-path=/home/log/nginx/access.log \
    --with-pcre=../pcre-8.36 \
    --with-pcre-opt=-fPIC \
    --with-openssl=../openssl-1.0.1m \
    --with-openssl-opt=-fPIC \
    --with-zlib=../zlib-1.2.8 \
    --with-zlib-opt=-fPIC \
    --with-backtrace_module \
    --without-select_module \
    --without-poll_module \
    --with-http_concat_module=shared \
    --with-http_sysguard_module=shared \
    --with-http_limit_conn_module=shared \
    --with-http_limit_req_module=shared \
    --with-http_split_clients_module=shared \
    --with-http_footer_filter_module=shared \
    --with-http_access_module=shared \
    --with-http_referer_module=shared \
    --with-http_rewrite_module=shared \
    --with-http_memcached_module=shared \
    --with-http_image_filter_module=shared \
    --without-http_upstream_check_module \
    --without-http_upstream_least_conn_module \
    --without-http_upstream_keepalive_module \
    --without-http_upstream_ip_hash_module \
    --without-http_geo_module \
    --http-client-body-temp-path=/var/nginx_temp/nginx_client \
    --http-proxy-temp-path=/var/nginx_temp/nginx_proxy \
    --http-fastcgi-temp-path=/var/nginx_temp/nginx_fastcgi \
    --user=www --group=www \
    --add-module=/usr/local/src/nginx-rtmp-module/  \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_gzip_static_module  \
    --with-http_random_index_module \
    --with-http_sub_module=shared \
    --with-http_dav_module && \
    make -j1 && make install
# clean packages and files
RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py" && \
    python get-pip.py && \
    pip install supervisor && \
    rm -fr pip.py && \
    yum remove -y gcc gcc-c++ autoconf && \
    yum autoremove -y && \
    yum clean all  && \
    rm -fr /usr/local/src

WORKDIR /
COPY ./nginx.conf /usr/local/nginx/conf/nginx.conf
COPY ./php.ini /usr/local/php/etc/
COPY ./php-fpm.conf /usr/local/php/etc/
COPY ./test.php /app/webroot/test.php
COPY ./supervisord.conf /etc/supervisord.conf
RUN chown -R www /app

CMD ["supervisord", "-c", "/etc/supervisord.conf", "-n"]
EXPOSE 80
#EXPOSE 443 9000
