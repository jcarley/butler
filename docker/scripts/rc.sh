#!/usr/bin/env bash

path=$0
SCRIPT_ROOT="${path%/*}"

source ${SCRIPT_ROOT}/config

docker run -i -t -v ${volume} ${links} --rm ${container} bash -c "cd /app && bundle exec rails c"
