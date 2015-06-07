#!/bin/bash

DOCKER_VERSION="${1:-LATEST}"
echo "Requested Docker version=$DOCKER_VERSION"

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
if [ "${DOCKER_VERSION}" = "LATEST" ]; then
  TAG_MESSAGE=$(git log --no-walk --tags --pretty="%h %d %cd" --max-count=1)
  GIT_TAG=$(echo $TAG_MESSAGE | sed -e 's/^.*tag: //' -e 's/).*$//' -e 's/,.*$//')
else
  GIT_TAG="v${DOCKER_VERSION}"
fi
echo "Using GIT_TAG=$GIT_TAG"

git checkout $GIT_TAG
export AUTO_GOPATH=1
./hack/make.sh dynbinary
