#!/bin/bash

ubuntu_devicemapper_config() {
  CUR_DIR=`pwd`
  MYDOCKER_CFGS="${CUR_DIR}/docker_configs"
  MYDOCKER_STORE="$CUR_DIR/docker_store"
  MYDOCKER_TMP=$MYDOCKER_STORE

  mkdir -p $CUR_DIR/docker_store
  docker_configs=$(cat <<-EOH
export DOCKER_TMPDIR="$MYDOCKER_TMP"
DOCKER_OPTS="--storage-driver=devicemapper -g $MYDOCKER_STORE"
EOH
)
  echo "$docker_configs" > "${MYDOCKER_CFGS}/docker"

  cp -a /etc/docker/daemon.json /etc/docker/daemon.json.bak
  cp -a /etc/default/docker /etc/default/docker.bak
  cp -a "${MYDOCKER_CFGS}/daemon.json" /etc/docker/daemon.json
  cp -a "${MYDOCKER_CFGS}/docker" /etc/default/docker

}

install_prompt() {
  echo "Do you want to use devicemapper instead of auf for docker (put 2 if you don't know)? (Enter:1 or 2)"
  select yn in "Yes" "No"; do
      case $yn in
          Yes ) printf "\nDoing config for devicemapper\n"; ubuntu_devicemapper_config; break;;
          No ) break;;
      esac
  done
}

ubuntu_install_docker() {
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
  
  install_prompt
  service docker restart

  docker run hello-world
}

# check OS
checkos() {
  if ! cat /proc/version | grep -i ubuntu; then
    printf "\nNot Ubuntu OS. Exiting...\n"
    exit 1
  elif `lsb_release -r | grep -e 16.04 > /dev/null 2>&1`;then
    printf "\nUbuntu 16.04 is installed.. continuing\n"
    ubuntu_install_docker
  fi
}

checkos

