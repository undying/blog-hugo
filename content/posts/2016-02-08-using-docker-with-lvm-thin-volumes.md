---
title: "Docker: Using docker with LVM Thin Pool"
date: 2016-02-08 00:21:00 +0300
tags:
- docker
- lvm
- datamapper
- thin
commentIssueId: 5
---

Docker is the nice tool for almost every use case in my sphere. It's easy to use, it's fast to build and deploy. 
Docker can be used with miscellaneous storage drivers such as btrfs, datamapper, overlayfs, aufs. A long time I was using docker with btrfs backend and everything seems to be nice, but when load on this server increased, corrupted layers are began to appear.

It looks like build process in the next RUN step unable to find files from previous step. I had no desire to dig into it because of time, so I decided to change storage backend. It may looks like the choice is big enough, in fact every variant is full of surprises. Some of them is still not in the linux kernel, some of them have serious bugs, and others is just slow.

Some time ago I heard abount LVM thin provisioning. It's relatively new feature and I had no use cases to use it. Now I have it, because docker can work with it. You can create Virtual Group directly on block device and pass it to docker daemon. It works fast enough to hold many parallel docker builds in a single moment in time. So, let's try it.

Creating <b>V</b>irtual <b>G</b>roup <b>docker</b>:
{% highlight bash %}
pvcreate /dev/sdb
vgcreate docker /dev/sdb
{% endhighlight %}

Now we shall create a volume for metadata. <a href="http://linux.die.net/man/8/lvcreate">man 8 lvcreate</a> gives us a formula for calculating a size for metadata volume.
{% highlight bash %}
(Pool_LV_size / Pool_LV_chunk_size * 64b)
{% endhighlight %}

Default chink size is 64KiB, now lets find desired metadata size.
{% highlight bash %}
echo $[799057190584.31995 / 65536 * 64]
  780329287.67999995
echo $[780329287.67999995/1024/1024]
  744.17999999999995
{% endhighlight %}

<b>780329287.67999995</b> - The VG size in bytes (744GiB)<br>
<b>65536</b> - chunk size in bytes (64KiB)

Now creating metadata volume with calculated size.
{% highlight bash %}
lvcreate -n docker-pool-meta -L 744M docker
  Logical volume "docker-pool-meta" created.
{% endhighlight %}

<p class="border_solid_red"><i>Beware that this metadata size may not be enough for your needs. In my case it was too small, so I was using metadata size about 16GiB. This is the maximum supported size for now, and at this time I'm testing how does it works.</i></p>

Next, we need to create a volume for data. In my situations I just use the rest size of virtual group. First, I was trying to create volume this way:
{% highlight bash %}
lvcreate -n docker-pool-data -l 100%FREE docker
  Logical volume "docker-pool-data" created.
{% endhighlight %}

It's successfully created, but It fails in the next step when we need to convert this two volumes to the thin pool.
{% highlight bash %}
lvconvert --type thin-pool --poolmetadata docker/docker-pool-meta docker/docker-pool-data
  WARNING: Converting logical volume docker/docker-pool-data and docker/docker-pool-meta to pool's data and metadata volumes.
  THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)
Do you really want to convert docker/docker-pool-data and docker/docker-pool-meta? [y/n]: y
  Volume group "docker" has insufficient free space (0 extents): 38102 required.
{% endhighlight %}

If in your case everything is fine, my congratulations, you can <a href="{{ page.url }}#final">skip</a> this part.

Looks like when pool is being creating lvm needs some extra space, in my situation it's 38102 extents. Okay, so I need to create volume with size smaller on 38102 extents.
Lets find the virtual group size in extents.
{% highlight bash %}
vgs -o +vg_free_count,vg_extent_count
  VG     #PV #LV #SN Attr   VSize   VFree  Free #Ext
  docker   1   2   0 wz--n- 744,18g     0     0 190511
{% endhighlight %}

Fine, now lets see how many extents uses metadata volume.
{% highlight bash %}
lvs -o +vg_extent_count
  LV               VG     Attr       LSize    #Ext
  docker-pool-meta docker twi-aotz-- 744,0m   185
{% endhighlight %}

Now, it's easy to find desired data volume size.
{% highlight bash %}
echo $[190511-38102-185]
  152224
{% endhighlight %}

{% highlight bash %}
lvremove docker/docker-pool-data
  Logical volume "docker-pool-data" successfully removed

lvcreate -n docker-pool-data -l 152224 docker
  Logical volume "docker-pool-data" created.
{% endhighlight %}

Time to convert it.

{% highlight bash %}
lvconvert --type thin-pool --poolmetadata docker/docker-pool-meta docker/docker-pool-data
  WARNING: Converting logical volume docker/docker-pool-data and docker/docker-pool-meta to pool's data and metadata volumes.
  THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)
{% endhighlight %}

<p id="final">That's it, volumes are converted to thin pool and now can be used by docker daemon. We need a few options to ask docker to use this pool.</p>

{% highlight bash %}
/usr/bin/docker daemon -H unix:///run/docker.sock -H tcp://0.0.0.0:2375 --dns=172.17.0.1 --storage-driver=devicemapper --storage-opt dm.thinpooldev=/dev/mapper/docker-docker--pool--data --storage-opt=dm.use_deferred_removal=true --storage-opt=dm.mountopt=noatime --storage-opt=dm.fs=xfs
{% endhighlight %}

<table class="border_solid_black">
  <tr><td><b>-H unix:///run/docker.sock</b></td><td></td><td>listen socket. needed for docker cli</td></tr>
  <tr><td><b>-H tcp://0.0.0.0:2375</b></td><td></td><td>listen tcp. using for remote docker build</td></tr>
  <tr><td><b>--dns=172.17.0.1</b></td><td></td><td>pass to all new containers this ip as DNS resolver*</td></tr>
  <tr><td><b>--storage-driver=devicemapper</b></td><td></td><td>use devicemapper as storage driver</td></tr>
  <tr><td><b>--storage-opt dm.thinpooldev=/dev/mapper/docker-docker--pool--data</b></td><td></td><td>pass thin pool name to the docker daemon</td></tr>
  <tr><td><b>--storage-opt=dm.use_deferred_removal=true</b></td><td></td><td>support deffered devices removal</td></tr>
  <tr><td><b>--storage-opt=dm.mountopt=noatime</b></td><td></td><td>small FS optimisation</td></tr>
  <tr><td><b>--storage-opt=dm.fs=xfs</b></td><td></td><td>use XFS as root volume for containers</td></tr>
</table>
<table>
  <tr><td>*</td><td>I'm using local <a href="https://wiki.archlinux.org/index.php/Dnsmasq">dnsmasq</a> to cache most frequent dns requests</td></tr>
</table>

At this time I'm actively testing this solution with thin pools so this article may be updated from time to time If I'll find some new problems or features.
In fact as I think, this is the most acceptable solution for now in ratio speed/safety. Maybe soon we will see something more interesting, I hope so.

<h4>Links:</h4>

<ul>
  <li><a href="http://linux.die.net/man/8/lvcreate">man 8 lvcreate</a></li>
  <li><a href="http://man7.org/linux/man-pages/man7/lvmthin.7.html">man 7 lvmthin</a></li>
  <li><a href="https://docs.docker.com/engine/reference/commandline/daemon/">docker docs</a></li>
</ul>

