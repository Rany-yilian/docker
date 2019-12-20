FROM centos:7
MAINTAINER yilian

ADD nginx-1.12.0.tar.gz /usr/local/src
RUN yum -y update
RUN yum -y install wget gcc gcc-c++ make pcre-devel vim libxml2 libxml2-devel openssl openssl-devel bzip2 bzip2-devel libcurl libcurl-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel gmp gmp-devel libmcrypt libmcrypt-devel readline readline-devel libxslt libxslt-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel ncurses curl gdbm-devel db4-devel libXpm-devel libX11-devel gd-devel gmp-devel expat-devel xmlrpc-c xmlrpc-c-devel libicu-devel libmcrypt-devel libmemcached-devel

#install nginx
#
RUN useradd -s /sbin/nologin nginx
WORKDIR /usr/local/src/nginx-1.12.0
RUN ./configure --prefix=/usr/local/nginx --user=nginx --group=nginx --with-http_ssl_module --with-http_stub_status_module && make && make install
ADD nginx.conf.tar.gz /usr/local/nginx/conf
ADD vhost.tar.gz /usr/local/nginx/conf
ADD www.tar.gz /
ADD nginx.service /usr/lib/systemd/system
ENV PATH /usr/local/nginx/sbin:$PATH
EXPOSE 80

#install php
#
ADD php-7.1.0.tar.gz /usr/local/src
WORKDIR /usr/local/src/php-7.1.0
RUN ./configure \
--prefix=/usr/local/php \
--enable-fpm \
#--enable-zip \
--enable-mysqlnd-compression-support \
--enable-opcache && make && make install
ENV PATH /usr/local/php/bin:$PATH

RUN cp php.ini-production /etc/php.ini
RUN cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
RUN cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf
RUN cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
RUN chmod +x /etc/init.d/php-fpm

COPY init.sh /www
RUN chmod +x /www/init.sh
CMD ["/www/init.sh"]
