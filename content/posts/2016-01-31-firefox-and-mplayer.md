---
title: "Using FireFox to play video with Mplayer on Windows"
date: 2016-01-31 16:30:00 +0300
tags:
- firefox
- mplayer
- youtube
- mpv
- video
commentIssueId: 4
---

Some time ago I was visiting at my mom. We live a far away from each other so frequently visits is not so easy. She using a pretty old computer which I were overclocking a long time ago. It's a <a href="http://www.cpu-world.com/CPUs/K7/AMD-Athlon%20XP%203200+%20-%20AXDA3200DKV4E.html">AMD Barton 3200+</a> with 2GB DDR RAM and <a href="http://www.nvidia.ru/page/geforce_6600.html">Geforce 6600 GT</a>.

It was a great PC a long time ago. Even now it works fine, except when you are want to watch video online. You can surf the internet, work with documents but when you want to watch some new series of your favorite serial, computer is getting really slow.

Well, my mom loves serials so I have to do something. I'm not able to buy new PC right now, because this economic situation in country is not quite comfortable for buying something, I need some time to save money for new computer but serials can't wait.

The main problem is a Flash. If I only could play videos with other media player, the situation might be much better. A bit searching in internet gives me information that I can do so. The main limitation is to use Firefox browser. Well, for Barton 3200 it's not the limitation, it's the only way, because Chrome is not supporting such old hardware =(.

What we will need:
<ol>
  <li><a href="https://www.mozilla.org/ru/firefox/new/">Browser FireFox</a></li>
  <li><a href="https://addons.mozilla.org/en-US/firefox/addon/flashgot/">FireFox application FlashGot</a></li>
  <li><a href="http://mplayerwin.sourceforge.net/downloads.html">Mplayer</a> and <a href="https://www.mplayerhq.hu/MPlayer/releases/codecs/windows-essential-20071007.zip">Codecs</a></li>
</ol>

I will omit how to install FireFox browser, but I'll share the <a href="https://www.mozilla.org/ru/firefox/new/">link</a> to download it.

<h4>Mplayer</h4>

First, download <a href="http://mplayerwin.sourceforge.net/downloads.html">Mplayer</a> and unpack it.
<img class="border_solid_black" src="https://pp.vk.me/c629510/v629510865/3f3ba/qvFUegmliG4.jpg"/>
<br><br>

Then you will need a codecs, you can find them <a href="https://www.mplayerhq.hu/MPlayer/releases/codecs/windows-essential-20071007.zip">here</a>. Check <a href="https://www.mplayerhq.hu/MPlayer/releases/codecs/">this link</a> for latest codecs versions.
Just unpack them to <b>codecs</b> directory under mplayer directory.
<img class="border_solid_black" src="https://pp.vk.me/c629510/v629510865/3f3c3/QG_ozrrGcJY.jpg"/>
<br><br>
<img class="border_solid_black" src="https://pp.vk.me/c629510/v629510865/3f3cc/lajDcHUkkUg.jpg"/>
<br><br>

<h4>FlashGot</h4>

Now we have to install <a href="https://addons.mozilla.org/en-US/firefox/addon/flashgot/">FlashGot</a> plugin for FireFox.
<img class="border_solid_black" src="https://pp.vk.me/c629510/v629510865/3f3d5/oFz0MDa4wiI.jpg"/>
<br><br>

And configure it.

<img class="border_solid_black" src="https://pp.vk.me/c629510/v629510865/3f3dc/kjPcyh-rxKA.jpg"/>
<br><br>
We need to create downloader <b>Mplayer</b> in main section, and then select in in <b>Media</b> section.

<img class="border_solid_black" src="https://pp.vk.me/c629510/v629510865/3f3e3/WxyynzGthxw.jpg"/>
<br><br>

And that's all!

<h4>Now, how to use it.</h4>

Lets try to open page that contains the video we want to watch.
<img class="border_solid_black" src="https://pp.vk.me/c629510/v629510865/3f3ec/17HN0DVd2rE.jpg"/>
We can see the FlashGot icon at the Firefox address bar.
Click on it with right mouse button and the menu will appear. In this menu you can see multiple different quality variants for out video. FlashGot will run mplayer with address of video with quality you chose in this menu.

<img class="border_solid_black" src="https://pp.vk.me/c629510/v629510865/3f3f5/8mXH_8rm-N4.jpg"/>
<img class="border_solid_black" src="https://pp.vk.me/c629510/v629510865/3f3fe/yu4onZtLdIg.jpg"/>
<img class="border_solid_black" src="https://pp.vk.me/c629510/v629510865/3f406/Niq4Yvwh9wY.jpg"/>
<br><br>

Mplayer shortcats you may want to know:
```sh
 keyboard control
        LEFT and RIGHT
             Seek backward/forward 10 seconds.
        UP and DOWN
             Seek forward/backward 1 minute.
        PGUP and PGDWN
             Seek forward/backward 10 minutes.
        [ and ]
             Decrease/increase current playback speed by 10%.
        { and }
             Halve/double current playback speed.
        BACKSPACE
             Reset playback speed to normal.
        p / SPACE
             Pause (pressing again unpauses).
        .
             Step forward.  Pressing once will pause movie, every consecutive press will play one frame and then go into pause mode again (any other key unpauses).
        q / ESC
             Stop playing and quit.
        + and -
             Adjust audio delay by +/- 0.1 seconds.
        / and *
             Decrease/increase volume.
        9 and 0
             Decrease/increase volume.
        m
             Mute sound.
        f
             Toggle fullscreen (also see -fs).
        T
             Toggle stay-on-top (also see -ontop).
```

Well done!
Now we can watch our favorite serials with mplayer and even with higher quality than it was with Flash player, because mplayer works much faster then the last one.

I really liked this solution, so I decided to make the same configuration on my linux box. The main difference is that I'm using <a href="https://mpv.io/">Mpv</a> player instead of mplayer, in the rest it works the same way.

<h4>Links</h4>
<ul>
  <li><a href="https://www.mozilla.org/ru/firefox/new/">Mozilla Firefox</a></li>
  <li><a href="https://addons.mozilla.org/en-US/firefox/addon/flashgot/">FlashGot</a></li>
  <li><a href="http://mplayerwin.sourceforge.net/downloads.html">Mplayer</a></li>
  <li><a href="https://www.mplayerhq.hu/MPlayer/releases/codecs/windows-essential-20071007.zip">Mplayer Codecs</a></li>
  <li><a href="https://mpv.io">Mpv</a></li>
</ul>

