#!/usr/bin/env bash

path=$0
SCRIPT_ROOT="${path%/*}"

source ${SCRIPT_ROOT}/config

docker run -i -t -p 3000:3000 -v ${volume} ${links} --rm ${container} /bin/bash
