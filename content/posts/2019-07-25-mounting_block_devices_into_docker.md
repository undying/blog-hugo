---
title: "Docker: Mounting block devices into container"
date: 2019-07-25 14:27:00 +0000
tags:
- mount
- block
- lvm
- docker
- container
commentIssueId: 8
---

Today was curious is it possible to mount block device into a docker container without mounting it on system.
It's not well documented but found one interesting <a href="https://github.com/moby/moby/issues/37893#issuecomment-424535343">comment </a> in github.

So, if --mount option in `docker run` command is "magic" on top of "mount" system call, we can use it.
After experimenting a bit here is an example mounting lvm volumes.

First, let's create loop device for LVM:

{% highlight bash %}
  dd if=/dev/zero of=/tmp/loop bs=1M count=100
  losetup /dev/loop0 /tmp/loop
{% endhighlight %}

Then, making an LVM device:

{% highlight bash %}
  pvcreate /dev/loop0
  vgcreate vg1 /dev/loop0
  lvcreate --size 90M --name lv1 vg1
  mkfs.xfs /dev/vg1/lv1
{% endhighlight %}

And finally let's run container and mount block device:

{% highlight bash %}
docker run \
  --rm -it \
  --mount='type=volume,dst=/opt,volume-driver=local,volume-opt=type=xfs,volume-opt=device=/dev/vg1/lv1' \
  ubuntu:18.04 bash
{% endhighlight %}

That's it.

