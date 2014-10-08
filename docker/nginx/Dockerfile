FROM base:latest

RUN sudo add-apt-repository ppa:nginx/stable
RUN sudo apt-get update
RUN sudo apt-get install -y nginx

ADD nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
EXPOSE 443

CMD ["/usr/sbin/nginx"]
