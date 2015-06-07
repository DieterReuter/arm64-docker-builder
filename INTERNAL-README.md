# arm64-docker-builder - internal notes
(just in case you run into some similar issues)


## Step 1: running `install-arm64-devtools.sh`

### Problem 1: qemu crashed on `install-arm64-devtools.sh`
This only happens because I had too few memory on the host machine. A good working setting is 1 GByte for the Ubuntu host machine and 512 MByte for the QEMU machine.


## Step 2: running `sudo dpkg --configure -a` after restart of QEMU machine
see: http://unix.stackexchange.com/questions/109698/dpkg-dependency-problems-prevent-configuration-of-initramfs-tools

### Problem 2: after reboot, run `sudo dpkg --configure -a` show errors
```
$ sudo dpkg --configure -a

Setting up initramfs-tools (0.103ubuntu15) ...
update-initramfs: deferring update (trigger activated)
Processing triggers for initramfs-tools (0.103ubuntu15) ...
update-initramfs: Generating /boot/initrd.img-3.19.0-18-generic
Unsupported platform.
run-parts: /etc/initramfs/post-update.d//flash-kernel exited with return code 1
dpkg: error processing package initramfs-tools (--configure):
 subprocess installed post-installation script returned error exit status 1
Errors were encountered while processing:
 initramfs-tools
```


## Step 3: running `sudo dpkg --configure -a --force-depends` 
```
$ sudo dpkg --configure -a --force-depends

Setting up initramfs-tools (0.103ubuntu15) ...
update-initramfs: deferring update (trigger activated)
Processing triggers for initramfs-tools (0.103ubuntu15) ...
update-initramfs: Generating /boot/initrd.img-3.19.0-18-generic
Unsupported platform.
run-parts: /etc/initramfs/post-update.d//flash-kernel exited with return code 1
dpkg: error processing package initramfs-tools (--configure):
 subprocess installed post-installation script returned error exit status 1
Errors were encountered while processing:
 initramfs-tools
```


## Step 4: running `sudo apt-get install -f`

This also tries to generate `/boot/initrd.img`, takes a long time again...
```
$ sudo apt-get install -f

Reading package lists... Done
Building dependency tree
Reading state information... Done
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
1 not fully installed or removed.
After this operation, 0 B of additional disk space will be used.
Setting up initramfs-tools (0.103ubuntu15) ...
update-initramfs: deferring update (trigger activated)
Processing triggers for initramfs-tools (0.103ubuntu15) ...
update-initramfs: Generating /boot/initrd.img-3.19.0-18-generic

Unsupported platform.
run-parts: /etc/initramfs/post-update.d//flash-kernel exited with return code 1
dpkg: error processing package initramfs-tools (--configure):
 subprocess installed post-installation script returned error exit status 1
E: Sub-process /usr/bin/dpkg returned an error code (1)
W: Operation was interrupted before it could finish
```


## RESUMEE

OK, let's skip all these and just ignore it.
Just check, if our dependent packages are installed:
```
$ dpkg -l | grep btrfs-tools
ii  btrfs-tools                      3.17-1.1                     arm64        Checksumming Copy on Write Filesystem utilities
```
```
$ dpkg -l | grep libsqlite3-dev
ii  libsqlite3-dev:arm64             3.8.7.4-1                    arm64        SQLite 3 development files
```
```
$ dpkg -l | grep libdevmapper-dev
ii  libdevmapper-dev:arm64           2:1.02.90-2ubuntu1           arm64        Linux Kernel Device Mapper header files
```

OK, everything is GREEN.
Go ahead and compile Docker.
