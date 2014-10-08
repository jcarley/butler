#!/usr/bin/env bash

path=$0
SCRIPT_ROOT="${path%/*}"

source ${SCRIPT_ROOT}/config

docker stop ${name}
docker rm ${name}
docker build -t rails /home/vagrant/apps/butler
docker run -d -p ${port} -v ${volume} ${links} --name ${name} ${container}
