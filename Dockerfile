# docker build -t fbelov/nginx-dev .
# docker push fbelov/nginx-dev

#to run this container use
#docker run --net=host -t -v /job_on_current_machine/:/job fbelov/nginx-dev &
#note: don't forget to provide /job/nginx/conf/nginx.conf file!

FROM phusion/baseimage

# add sources of nginx-upload-module to root of this project
RUN mkdir /docker-build/
ADD nginx-upload-module /docker-build/nginx-upload-module

#port
EXPOSE 80

#copy docker file
ADD Dockerfile /Dockerfile

#RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update
RUN apt-get install openssh-server -y

#nginx build
#http://blog.thehippo.de/2012/12/server/install-nginx-from-source-on-ubuntu/
RUN apt-get -y install wget build-essential zlib1g-dev libpcre3-dev libssl-dev libxslt1-dev libxml2-dev libgd2-xpm-dev libgeoip-dev libgoogle-perftools-dev libperl-dev
RUN mkdir /home/fbelov/
WORKDIR /home/fbelov
RUN wget http://nginx.org/download/nginx-1.7.10.tar.gz
RUN tar xvfvz nginx-1.7.10.tar.gz
WORKDIR /home/fbelov/nginx-1.7.10/
RUN ./configure --prefix=/usr/local/nginx --sbin-path=/usr/local/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/run/nginx.pid --lock-path=/run/lock/subsys/nginx --user=nginx --group=nginx --with-file-aio --with-ipv6 --with-http_ssl_module --with-http_spdy_module --with-http_realip_module --with-http_addition_module --with-http_xslt_module --with-http_image_filter_module --with-http_geoip_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_degradation_module --with-http_stub_status_module --with-http_perl_module --with-mail --with-mail_ssl_module --with-pcre --with-google_perftools_module --with-http_auth_request_module --with-debug --add-module=/docker-build/nginx-upload-module
RUN make
RUN make install
RUN useradd nginx

#run nginx
RUN mkdir /etc/service/nginx
ADD service/nginx.sh /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run

#COMMON PARTS FOR MOST CONTAINERS
# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
