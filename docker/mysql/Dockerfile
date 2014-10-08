FROM base:latest

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y mysql-server mysql-client libmysqlclient-dev
RUN rm -rf /var/lib/mysql/mysql
RUN rm -rf /var/lib/apt/lists/*

ADD start.sh /start.sh
RUN chmod 755 /start.sh

EXPOSE 3306

VOLUME ["/var/lib/mysql"]

CMD ["/start.sh"]
