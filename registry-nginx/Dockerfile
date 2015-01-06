FROM ubuntu

RUN apt-get update && apt-get -y upgrade

RUN apt-get -y install nginx-extras && \
    rm /var/lib/apt/lists/*_*

RUN rm /etc/nginx/sites-enabled/default

ADD conf/nginx.conf /etc/nginx/nginx.conf
ADD conf/registry-docker /etc/nginx/sites-enabled/registry-docker

EXPOSE 8080

CMD ["/usr/sbin/nginx"]
