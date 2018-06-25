#!/bin/sh
set -ex

wget https://github.com/antirez/redis/archive/5.0-rc3.tar.gz -O /tmp/redis-5.0-rc3.tar.gz
tar -xvf /tmp/redis-5.0-rc3.tar.gz
cd redis-5.0-rc3 && make
./src/redis-server --daemonize yes
