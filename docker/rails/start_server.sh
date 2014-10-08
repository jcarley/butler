#!/usr/bin/env bash

cd /app
bundle install
bundle exec rake tmp:clear
bundle exec rake tmp:create
bundle exec rake db:create db:migrate
bundle exec rails s puma
