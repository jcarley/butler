#!/usr/bin/env bash

path=$0
script_root="${path%/*}"
docker_root=$(dirname $(readlink -e $script_root))
images='base mysql nginx ..'

for f in $images; do
  path=$docker_root/$f
  if [[ $f == '..' ]]; then
    name=$(basename $(readlink -e $path))
  else
    name=$f
  fi
  echo "Building Docker image:"
  echo "  Image Name: $name"
  echo "  Dockerfile: $path"
  docker build -t $name $path
  echo ""
done

