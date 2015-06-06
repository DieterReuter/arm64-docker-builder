#!/bin/bash

DOCKER_VERSION=1.6.2
DOCKER_VERSION=1.7.0-rc1
DOCKER_VERSION=1.7.0-rc2

mkdir -p ~/src/
cd ~/src/
if [ ! -d ./docker ]; then
  echo "Clone into docker/docker repository"
  git clone https://github.com/docker/docker
fi

echo "Fetch latest changes of docker/docker repository"
cd ~/src/docker/
git checkout master
git fetch -q --all -p

# detect latest Docker release tag
TAG_MESSAGE=$(git log --no-walk --tags --pretty="%h %d %cd" --max-count=1)
git_tag=$(echo $TAG_MESSAGE | sed -e 's/^.*tag: //' -e 's/).*$//' -e 's/,.*$//')
echo "Docker version=$git_tag"

#git checkout v$DOCKER_VERSION
git checkout $git_tag
./hack/make.sh dynbinary
