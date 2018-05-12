#!/bin/bash
set -x
set -e
shopt -s expand_aliases

alias zold="$1"

port=`python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()'`

mkdir server
cd server
zold node --host=localhost --port=${port} --bind-port=${port} --threads=0 &
pid=$!
trap "kill -9 $pid" EXIT
cd ..

while ! nc -z localhost ${port}; do
  sleep 0.1
done

zold remote clean
zold remote add localhost ${port}
zold remote show

zold --public-key id_rsa.pub create 0000000000000000
zold --private-key id_rsa --trace pay 0000000000000000 af5788fcadd710c5 14.99 'To save the world!'
zold show
zold show 0000000000000000

zold push 0000000000000000
zold fetch 0000000000000000
zold diff 0000000000000000
zold --trace merge 0000000000000000

echo 'DONE'