#!/bin/bash

# ./run2.sh env-'db:server-db=mysql be:server-be=apache fe:server-fe1,server-fe2=nginx' v:2

playbook='play.yml'
echo '---' > $playbook

cat $playbook

for i in "$@"; do
  if [[ "$i" =~ "env" ]];then
    env=`echo ${i} | cut -c 5-| tr -d \'`
    for e in $env; do 
      role=`echo $e | cut -d= -f2`
      tmp=`echo $e | cut -d= -f1`
      category=`echo $tmp | cut -d: -f1`
      host=`echo $tmp | cut -d: -f2`
      echo $category $role $host

      echo "- hosts: $category"                  >> $playbook 
      echo "  gather_facts: false"              >> $playbook
      echo "  vars_files:"                      >> $playbook
      echo "    - roles/${role}/vars/main.yml"  >> $playbook
      echo "  user: root"                       >> $playbook
      echo "  roles:"                           >> $playbook
      echo "    - ${role}"                      >> $playbook
      echo                                      >> $playbook
    done
  fi

  if [[ "$i" =~ "v:" ]];then
    v=`echo $i | cut -d':' -f2`
    verbose=-`seq $v | xargs -I{} echo -n v`
  fi
done

echo ENV $env
#./containerize.py db:server-db=mysql be:server-be=apache fe:server-fe1,server-fe2=nginx
./containerize.py $env

cmd="ansible-playbook ${playbook} $verbose" # --tags "restart"              # $1 playbook.yml $2 -v
echo $cmd
$cmd
