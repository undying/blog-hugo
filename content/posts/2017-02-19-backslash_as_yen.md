---
title: "Gentoo: Backslash as Yen char"
date: 2017-02-19 15:47:00 +0300
tags:
- gentoo
- backslash
- yen
---

If while browsing the internet you have a problem with backslash character which displayed as yen sign you can fix it this way.

First, let's install the appropriate fonts.

```sh
emerge -av media-fonts/droid
```

Then we have to enable them for wide system.

```sh
eselect fontconfig enable 59-google-droid-sans.conf
eselect fontconfig enable 59-google-droid-sans-mono.conf
eselect fontconfig enable 59-google-droid-serif.conf
```

Next step is to clean fonts cache.

```sh
fc-cache -rf
```

That's all.

P.S.
Also I had a problem displaying cyrillic characters. Droid fonts also helps with that, but I found that chinese fonts (media-fonts/wqy-zenhei) can help. 

