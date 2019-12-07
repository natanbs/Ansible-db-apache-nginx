#!/usr/bin/python3
""" This script creates a customized amount of roles and containers """

import os
import sys

def usage():
    """ Help """
    print(""" 
      This script creates a customized amount of roles and containers.

      Usage:   ./containerize.py role:containers
      Example: ./containerize.py db:one be:two fe:three,four
    """)

if len(sys.argv) < 2:
    usage()
    exit(0)

def del_dockers():
    """ Delete exisiting env """
    print()
    print('Deleting all existsing containers')
    # Stop all existsing containers
    del_containers = os.popen("docker ps -a | grep -v CONTAINER | cut -d ' ' -f 1").read()
    if del_containers != '':
        os.system("docker ps -a | grep -v CONTAINER |  cut -d' ' -f1 | xargs sudo docker stop > /dev/null")

        # Delete all containers and images except img_master and img_node
        os.system("docker ps -a | grep -v CONTAINER | cut -d' ' -f1 | xargs docker rm > /dev/null; for i in `docker images | grep -Ev 'img|sickp' | awk '{print $3}' | grep -v IMA > /dev/null`; do docker rmi $i; done")
del_dockers()

# Check if build exists
eg = os.popen('docker images |grep eg_sshd && echo Y || echo N').read().strip()
if eg == 'N':
    os.system('docker build -t eg_sshd .')

inventory = 'hosts'
Containers = sys.argv[1:]
print()
print('Creating Containers: ', Containers)
open(inventory, 'w').close()
for Role in Containers:
    print()
    role = Role.rsplit('=', 1)[1]      # mysql / mariadb / mongodb / apache / nginx
    tmp = Role.rsplit('=', 1)[0]       # Category and hosts
    category = tmp.rsplit(':', 1)[0]
    cat = '[' + str(category) + ']'
    hosts = tmp.rsplit(':', 1)[1].split(',')
    with open(inventory, 'a') as f:
        f.write('\n' + cat + '\n')
        for h in hosts:
            print(cat, role, h)
            os.system('docker run -dP --name=' + h + ' eg_sshd ')
            ip = os.popen('docker inspect -f "{{ .NetworkSettings.Networks.bridge.IPAddress }}" ' + h).read()
            f.write(h + ' ansible_host=' + ip)
    f.close

# Get the Containers IP
print()
print('Inventory file ' + inventory)
os.system('cat ' + inventory)

# Create keys on Containers
print()
home = os.getenv("HOME")
with open(home + '/.ssh/config', 'w+') as f:
    f.write('StrictHostKeyChecking no\nUserKnownHostsFile /dev/null')
f.close
os.system("""for i in $(cat hosts | grep -v '\[' | cut -d= -f2); do cat ~/.ssh/id_rsa.pub | sshpass -p 1234 ssh root@${i} "cat >> .ssh/authorized_keys && echo Key copied to ${i}"; done""")

# Show the created images and the running containers
os.system('echo; docker images; echo; docker ps -a; echo')
