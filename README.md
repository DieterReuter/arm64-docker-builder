# arm64-docker-builder

This repo contains all necessary details and scripts how to compile `Docker` 
on an ARM64 (or AARCH64) machine which is running Ubuntu 15.04. This works well, even in a QEMU emulated AARCH64 
machine with an Ubuntu 15.04 Cloud Image for ARM64. I've tested all these steps with a QEMU box which could be 
run with the help of `vagrant` in VirtualBox or on DigitalOcean with the following 
repo https://github.com/DieterReuter/qemu-arm-box.

## Background

For the last six months or so, I was working hard in my spare time to get Docker running easily for some ARM 32bit 
systems like the Raspberry Pi. For this year there should be a few new ARM devices coming on the market with 64bit CPUs, 
and I'd like to get Docker running on these ARM64 devices as soon as possible.

I don't have any ARM64 machine at hand, so I tried to set up a QEMU emulated ARM64 (aka AARCH64) in a reproducible way. 
I choose Vagrant and created a box running Ubuntu 15.04. With the help of Vagrant it was easy to set up such a box in 
a local VirtualBox (on my MacBookPro) and also the same way on a DigitalOcean Droplet. I think, now it's easy for everybody
to spin up such a QEMU ARM64 box within 5 or 10 minutes on your local machine or in the cloud.


### Prerequisites

If you don't have an ARM64 machine at hand like me, you have to create a QEMU box first. This can be done with my repo https://github.com/DieterReuter/qemu-arm-box. Once your ARM64 machine is up and running, just login and go ahead.


### Step 1 - install dependencies

First we have to install some development dependencies like Git, Curl, GOLANG and some more specific dependencies for Docker like btrfs, sqlite and devmapper. Please keep in mind, this can take a serious long time on a QEMU emulated machine.
```
$ ./install-arm64-devtools.sh
```

Maybe if you run into trouble that the install process gets interrupted while generating a new `/boot/initrd.img`, you can fix this with the following commands (of course inside the ARM64 machine):
```
$ sudo dpkg --configure -a --force-depends
$ sudo apt-get install -f
```

OK, let's skip all these problems for now and just ignore it. For a QEMU machine it could also happens that we have to reboot the machine.
At least, we should check, if our dependent packages are already installed:
```
$ dpkg -l | grep -E "btrfs-tools|libsqlite3-dev|libdevmapper-dev"
ii  btrfs-tools                      3.17-1.1                     arm64        Checksumming Copy on Write Filesystem utilities
ii  libdevmapper-dev:arm64           2:1.02.90-2ubuntu1           arm64        Linux Kernel Device Mapper header files
ii  libsqlite3-dev:arm64             3.8.7.4-1                    arm64        SQLite 3 development files
```
OK, everything is there. Let's go ahead and compile Docker.


### Step 2 - compile the latest version of Docker

The compile script will first clone into the docker/docker repo, so this will take some time. But don't worry for subsequent builds the script just fetches only the latest changes which is much faster. The compile time depends on your host machine and takes around 5 to 20 minutes, the later on a QEMU emulated machine on DigitalOcean; on a local VirtualBox machine it could be faster. And on real hardware you should get the best performance - but who has already an ARM64 power horse at hand?
```
$ ./compile-docker.sh

Fetch latest changes of docker/docker repository
Previous HEAD position was 7ddecf7... Bump version to v1.7.0
Switched to branch 'master'
Your branch is up-to-date with 'origin/master'.
Docker version=v1.7.0-rc2
Note: checking out 'v1.7.0-rc2'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by performing another checkout.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -b with the checkout command again. Example:

  git checkout -b new_branch_name

HEAD is now at 7ddecf7... Bump version to v1.7.0
# WARNING! I don't seem to be running in the Docker container.
# The result of this command might be an incorrect build, and will not be
#   officially supported.
#
# Try this instead: make all
#

---> Making bundle: dynbinary (in bundles/1.7.0-rc2/dynbinary)
go build: when using gccgo toolchain, please pass linker flags using -gccgoflags, not -ldflags
Created binary: bundles/1.7.0-rc2/dynbinary/dockerinit-1.7.0-rc2
Building: bundles/1.7.0-rc2/dynbinary/docker-1.7.0-rc2
go build: when using gccgo toolchain, please pass linker flags using -gccgoflags, not -ldflags
Created binary: bundles/1.7.0-rc2/dynbinary/docker-1.7.0-rc2
```

Here are our fresh build artifacts:
```
$ ls -al bundles/1.7.0-rc2/dynbinary/

total 21052
drwxrwxr-x 2 ubuntu ubuntu     4096 Jun  7 13:13 .
drwxrwxr-x 3 ubuntu ubuntu     4096 Jun  7 12:54 ..
lrwxrwxrwx 1 ubuntu ubuntu       16 Jun  7 13:13 docker -> docker-1.7.0-rc2
-rwxrwxr-x 1 ubuntu ubuntu 17582904 Jun  7 13:13 docker-1.7.0-rc2
-rw-rw-r-- 1 ubuntu ubuntu       51 Jun  7 13:13 docker-1.7.0-rc2.md5
-rw-rw-r-- 1 ubuntu ubuntu       83 Jun  7 13:13 docker-1.7.0-rc2.sha256
lrwxrwxrwx 1 ubuntu ubuntu       20 Jun  7 12:58 dockerinit -> dockerinit-1.7.0-rc2
-rwxrwxr-x 1 ubuntu ubuntu  3945424 Jun  7 12:58 dockerinit-1.7.0-rc2
-rw-rw-r-- 1 ubuntu ubuntu       55 Jun  7 12:58 dockerinit-1.7.0-rc2.md5
-rw-rw-r-- 1 ubuntu ubuntu       87 Jun  7 12:58 dockerinit-1.7.0-rc2.sha256
```

If you like, you can also build a specific release version of Docker:
```
$ ./compile-docker.sh 1.7.0-rc1
```


### Step 3 - quickly test the compiled Docker binary
```
$ ./bundles/1.7.0-rc2/dynbinary/docker-1.7.0-rc2 version

Client version: 1.7.0-rc2
Client API version: 1.19
Go version (client): go1.4.2 gccgo (Ubuntu 5.1~rc1-0ubuntu1) 5.0.1 20150414 (prerelease) [gcc-5-branch revision 222102]
Git commit (client): 7ddecf7
OS/Arch (client): linux/arm64
Get http:///var/run/docker.sock/v1.19/version: dial unix /var/run/docker.sock: no such file or directory. Are you trying to connect to a TLS-enabled daemon without TLS?
```

Success, it runs in client mode and the arch type is `linux/arm64`.


## Further steps

The next steps should be to get the Docker engine running in daemon mode on the ARM64 machine. But I think, this will take some more time to adjust the appropriate kernel options, include all needed kernel modules like Overlay filesystem and so on. And maybe also a serious amount of testing and possibly setting up a completely automated build server for compiling and testing Docker on ARM64 machines. This should get even better as soon as we have some real hardware to speed up the dev-test cycles.

Have fun to use this tutorial as a starting point, and please share your experience with me.

---
The MIT License (MIT)

Copyright (c) 2015 Dieter Reuter