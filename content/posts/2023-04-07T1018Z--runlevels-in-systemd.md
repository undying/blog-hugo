---
title: "Runlevels in Systemd"
date: 2023-04-07T10:18:38+03:00
tags:
- systemd
- runlevel
---

Once, when loading into [Asahi](/posts/2023-04-03t0000z--moving-from-macos-to-asahi-linux/), the keyboard stopped working after loading the X server.
It was necessary to boot into a bare terminal without starting the X server, but how to do it?

One of the rough options is to boot into bash as an init process.
The second option is to redefine the runlevel to the one in which X does not run.

To do this, when loading grub, go to the edit start line menu by pressing the **"e"** key.
Then we add a new runlevel (init) to the kernel parameters.

```sh
systemd.unit=multi-user.target
```

For example, if our upload command looks like this:

```sh
linux vmlinuz-linux-asahi-edge root=/dev/mapper/vg0-root rw cryptdevice=/dev/sda1:cryptroot resume=/dev/sda2 loglevel=3 quiet
```

Then we change it as follows by adding the unit parameter to the end of the line:

```sh
linux vmlinuz-linux-asahi-edge root=/dev/mapper/vg0-root rw cryptdevice=/dev/sda1:cryptroot resume=/dev/sda2 loglevel=3 quiet systemd.unit=multi-user.target
```

Exit the editing mode and load into the system pressing `Ctrl+X`

### References
- [Kernel Parameters](https://wiki.archlinux.org/title/kernel_parameters)
- [Systemd Targets](https://wiki.archlinux.org/title/Systemd#Targets)
- [Runlevels in Systemd](https://www.freedesktop.org/software/systemd/man/runlevel.html)
