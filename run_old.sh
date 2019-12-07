#!/bin/bash

#./containerize.py db:one be:two fe:three
./containerize.py db:one

for i in "$@"; do
  if [[ "$i" =~ "db:" ]];then
    db=`echo ${i} | cut -d: -f2`
    echo DB type: $db
    if [[ "$db" != "mysql" ]] && [[ "$db" != "mariadb" ]] && [[ $db != "mongodb" ]]; then
      echo incorrect db type
      echo Please choose one of the followig:
      echo mysql
      echo mariadb
      echo mongodb
      exit
    fi
  fi
done

cmd="ansible-playbook ${db}.yml $2"               # $1 playbook.yml $2 -v
echo $cmd
$cmd
