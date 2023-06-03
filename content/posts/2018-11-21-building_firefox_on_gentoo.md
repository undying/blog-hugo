---
title: "Gentoo: Building FireFox 63.0.3"
date: 2018-11-21 05:10:00 +0000
commentIssueId: 7
tags:
- gentoo
- building
- firefox
- cargo
---

Today I was trying to update FireFox on my Gentoo box and failed with error:

{% highlight bash %}
  0:06.75 checking rustc version... 1.30.1
  0:06.75 ERROR: Cargo package manager not found.
  0:06.75 To compile Rust language sources, you must have 'cargo' in your path.
  0:06.75 See https://www.rust-lang.org/ for more information.
  0:06.75
  0:06.75 You can install cargo by running './mach bootstrap'
  0:06.75 or by directly running the installer from https://rustup.rs/
  0:06.75
  0:06.79 *** Fix above errors and then restart with\
  0:06.79                "/usr/bin/gmake -f client.mk build"
  0:06.79 gmake: *** [client.mk:127: configure] Error 1
{% endhighlight %}

I have already installed virtual/cargo and dev-lang/rust.
Also I found where cargo was already installed:

{% highlight bash %}
  equery f dev-lang/rust|grep cargo
  /usr/bin/cargo-1.30.1
{% endhighlight %}

So the solution was simple:

{% highlight bash %}
  sudo eselect rust update
{% endhighlight %}

This creates link required for build:

{% highlight bash %}
  ls -l $(which cargo)
  lrwxrwxrwx 1 root root 21 Nov 21 08:03 /usr/bin/cargo -> /usr/bin/cargo-1.30.1
{% endhighlight %}

