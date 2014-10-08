FROM base:latest

ENV DEBIAN_FRONTEND noninteractive

# REPOS
RUN apt-get -y update
RUN add-apt-repository -y ppa:chris-lea/node.js
RUN apt-get -y update

RUN apt-get -y install git nodejs build-essential libc6-dev bison openssl libreadline6 \
                      libreadline6-dev zlib1g zlib1g-dev libssl-dev libyaml-dev libxml2-dev \
                      libxslt1-dev autoconf libmysqlclient-dev mysql-client

RUN git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv
RUN echo '# rbenv setup' > /etc/profile.d/rbenv.sh
RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> /etc/profile.d/rbenv.sh
RUN echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> /etc/profile.d/rbenv.sh
RUN echo 'eval "$(rbenv init - --no-rehash)"' >> /etc/profile.d/rbenv.sh
RUN chmod +x /etc/profile.d/rbenv.sh

# install ruby-build
RUN mkdir /usr/local/rbenv/plugins
RUN git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build
RUN git clone https://github.com/sstephenson/rbenv-gem-rehash.git /usr/local/rbenv/plugins/rbenv-gem-rehash
RUN git clone https://github.com/jf/rbenv-gemset.git /usr/local/rbenv/plugins/rbenv-gemset

ENV RBENV_ROOT /usr/local/rbenv

ENV PATH $RBENV_ROOT/bin:$RBENV_ROOT/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# install ruby2
RUN rbenv install 2.1.2
RUN rbenv global 2.1.2

# Install base gems
RUN gem install bundler --no-rdoc --no-ri
RUN rbenv rehash

# Preinstall majority of gems
WORKDIR /tmp
ADD ./Gemfile Gemfile
ADD ./Gemfile.lock Gemfile.lock
RUN bundle install --jobs 2

ADD ./docker/rails/etc/init/puma-manager.conf /etc/init/puma-manager.conf
ADD ./docker/rails/etc/init/puma.conf /etc/init/puma.conf
ADD ./docker/rails/etc/puma.conf /etc/puma.conf

# https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.7-linux-x86_64.tar.bz2
# RUN curl https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.7-linux-x86_64.tar.bz2 | sudo tar xjfv -
# RUN sudo ln -s /usr/local/share/phantomjs-1.9.7-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs

RUN curl http://phantomjs.googlecode.com/files/phantomjs-1.8.1-linux-x86_64.tar.bz2 | sudo tar xjfv - && sudo ln -s /usr/local/share/phantomjs-1.8.1-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs


# Rails app
# ADD ./docker/rails/start_server.sh /start_server.sh
# RUN chmod +x /start_server.sh

ENV RAILS_ENV development

EXPOSE 9292

# CMD ["/start_server.sh"]
CMD ["tail -f /app/log/development.log"]


