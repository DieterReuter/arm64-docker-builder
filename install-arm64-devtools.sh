#!/bin/bash

sudo apt-get update
sudo apt-get install -y golang

# Docker dependencies
#   ATTENTION: this creates a new /boot/initrd.img, takes a long time
sudo apt-get install -y btrfs-tools libsqlite3-dev libdevmapper-dev gcc
