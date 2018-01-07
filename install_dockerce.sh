#!/bin/bash

echo "Y" | apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

apt-key fingerprint 0EBFCD88

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

echo "Y" | apt-get update

echo "Y" | apt-get install vim

echo "Y" | apt-get install docker-ce

echo "Y" | apt-get install docker-ce=17.12.0~ce-0~ubuntu

CUR_DIR=`pwd`
MYDOCKER_CFGS="${CUR_DIR}/docker_configs"
MYDOCKER_STORE="$CUR_DIR/docker_store"
MYDOCKER_TMP=$MYDOCKER_STORE

mkdir -p $CUR_DIR/docker_store
docker_configs=$(cat <<EOH
export DOCKER_TMPDIR="$MYDOCKER_TMP"
DOCKER_OPTS="--storage-driver=devicemapper -g $MYDOCKER_STORE"
)

cp -a "${MYDOCKER_CFGS}/daemon.json" /etc/docker/daemon.json
cp -a "${MYDOCKER_CFGS}/docker" /etc/default/docker

service docker restart

docker run hello-world


