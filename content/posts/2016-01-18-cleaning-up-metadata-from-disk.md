---
title: "How to cleanup FS metadata from partition"
date: 2016-01-28 02:58:00 +0300
tags:
- fs
- raid
- hdd
---

Sometimes you I'm need to create new FS on partition, which was already used for something else (another FS, RAID, LVM).
I was wondering about most usable ways to clear metadata. Here is some I liked the most.

<b>first</b>
```sh
wipefs -a ${DEVICE}
```

<b>second</b>
```sh
dd if=/dev/zero of=${DEVICE} bs=512 seek=$(( $(blockdev --getsz ${DEVICE}) - 1024 )) count=1024
```

<b>third</b>
```sh
dmraid -r -E ${DEVICE}
```

<h4>Example</h4>

```sh
~ # mkfs.btrfs /dev/sdb
/dev/sdb appears to contain an existing filesystem (LVM2_member).
Error: Use the -f option to force overwrite.


~ # wipefs -a /dev/sdb
/dev/sdb: 8 bytes were erased at offset 0x00000218 (LVM2_member): 4c 56 4d 32 20 30 30 31


~ # mkfs.btrfs /dev/sdb
Btrfs v3.16.2
See http://btrfs.wiki.kernel.org for more information.

Turning ON incompat feature 'extref': increased hardlink limit per file to 65536
fs created label (null) on /dev/sdb
        nodesize 16384 leafsize 16384 sectorsize 4096 size 744.19GiB
```

This is not all the ways, but for me the most easy usable (except dd, in this case).

