---
title: "Pure Bash script for IO usage monitoring"
date: 2016-09-13 02:39:00 +0300
tags:
- bash
- io
- monitoring
commentIssueId: 6
---


I had the need to implement pure bash solution for IO usage monitoring without any tools installed on OS, do this fast and accurately.
After little reaserching about /sys/ filesystem the next script was born:

{% highlight bash %}
#! /bin/bash

SLEEP=0.01
declare -A ops=()

for dev in /sys/block/*;do
  dev=${dev##*/}
  ops+=( [${dev}]=0 )
done

for i in $(seq 1 100);do
  while read _ _ drive _ _ _ _ _ _ _ _ tasks _ _;do
    [ -n "${drive}" ] || continue
    case ${tasks} in
      0|[!1-9]) continue
    esac

    drive=${drive/[0-9]/}

    if [ -n "${ops[${drive}]}" ];then
      ops[${drive}]=$[ ops[${drive}] + 1 ]
    else
      ops+=( [${drive}]=1 )
    fi
  done < /proc/diskstats

  sleep ${SLEEP}
done

for dev in ${!ops[@]};do
  echo ${dev} ${ops[${dev}]}
done

{% endhighlight %}

The usage is simple:

{% highlight bash %}

./disk_io_usage.sh
xvdb 10
xvda 0

./disk_io_usage.sh
xvdb 20
xvda 0

{% endhighlight %}

