#!/usr/bin/env bash

container_running() {
  local anything=$(docker ps -q | awk 'BEGIN { ORS = ";" } { print $1}' | xargs echo -n)
  if [ $anything ]; then
    if [ $(docker inspect --format {{.Name}} $(docker ps -q) | grep $1) ]; then
      echo -n 'true'
    else
      echo -n ''
    fi
  else
    echo -n ''
  fi
}

container_exists() {
  local anything=$(docker ps -aq | awk 'BEGIN { ORS = ";" } { print $1}' | xargs echo -n)
  if [ $anything ]; then
    if [ $(docker inspect --format {{.Name}} $(docker ps -aq) | grep $1) ]; then
      echo -n 'true'
    else
      echo -n ''
    fi
  else
    echo -n ''
  fi
}

container_action() {
  if [ $(container_exists $1) ]; then
    if [ $(container_running $1) ]; then
      echo -n "nothing"
    else
      echo -n "start"
    fi
  else
    echo -n "run"
  fi
}

case $(container_action 'mysql_cont_1') in
  run)
    echo "running mysql ..."
    docker run -d --name mysql_cont_1 mysql:latest
    ;;
  start)
    echo "starting mysql ..."
    docker start mysql_cont_1 >/dev/null
    ;;
  *) echo "mysql_cont_1 is already running ...";;
esac

case $(container_action 'butler_cont_1') in
  run)
    echo "running butler_cont_1 ..."
    docker run -d -p 3000:3000 -v /home/vagrant/apps/butler:/app --link mysql_cont_1:db --name butler_cont_1 butler:latest >/dev/null
    ;;
  start)
    echo "starting butler_cont_1 ..."
    docker start butler_cont_1 >/dev/null
    ;;
  *) echo "butler_cont_1 is already running ...";;
esac

case $(container_action 'nginx_cont_1') in
  run)
    echo "running nginx_cont_1 ..."
    docker run -d --name nginx_cont_1 nginx:latest
    ;;
  start)
    echo "starting nginx_cont_1 ..."
    docker start nginx_cont_1 >/dev/null
    ;;
  *) echo "nginx_cont_1 is already running ...";;
esac

