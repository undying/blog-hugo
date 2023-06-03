---
title: "command not found: ck-unlock-session"
date: 2019-07-25 14:27:00 +0000
tags:
- gentoo
- kde
commentIssueId: 9
---

This evening I was updating my Gentoo laptop. While updating, my session were locked with the message, that to unlock it I have to use ck-unlock-session. Unfortunately shell told me that there is no such command on my laptop:

{% highlight bash %}
  └> ck-unlock-session
  zsh: command not found: ck-unlock-session
{% endhighlight %}

In the vastness of the Internet found the solution, but it's too long to remember:

{% highlight bash %}
  dbus-send --system --print-reply --dest="org.freedesktop.ConsoleKit" /org/freedesktop/ConsoleKit/Session1 org.freedesktop.ConsoleKit.Session.Unlock
{% endhighlight %}

`Session1` - session name and it may differs. Name can be found by `ck-list-sessions`

