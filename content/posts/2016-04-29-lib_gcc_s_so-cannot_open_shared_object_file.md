---
title: "libgcc_s.so: cannot open shared object file"
date: 2016-04-29 02:04:00 +0300
tags:
- gentoo
- gcc
commentIssueId: 5
---

Как то вечером, я решил, что стоит лечь по-раньше спать. Подумал, что надо бы выспаться, все дела, но перед этим просто загляну в ноутбук, и тут началось.
Для чего то я одновременно запустил rtorrent + emerge -vuDN @world. Стоит ли говорить, что система установлена на шпиндельном hdd, поверх которого работает ssd cache (Bcache).
Видимо из-за нагрузки, ноутбук завис и ни на какие действия не реагировал. "Семь бед - один ресет", подумал я и перезагрузил ноутбук.
Система загрузилась быстрее обычного, чем меня смутила. Ввожу логин/пароль и терминал падает обратно с приглашением залогиниться. "Отлично, лег по-раньше...".
Записав на видео процесс загрузки и просмотрев его в замедленном режиме, я заметил, что перед приглашением терминала, вылитают ошибки:

{% highlight bash %}
error while loading shared libraries: libgcc_s.so.1: cannot open shared object file: no such file or directory
{% endhighlight %}

"Может еще не все потеряно?" - затеплился луч надежды.
Начинаю судорожно перебирать все загрузочные флешки, ни одна не подходит, то винда, то не работающая федора. Записал новую, загружаюсь...
Теперь нужно вспомнить, как монтировать мои диски, все-таки Luks + BCache.
Поиск в интернете, нашел:

{% highlight bash %}
modprobe bcache

echo /dev/sdb > /sys/fs/bcache/register #cache device
echo /dev/sda4 > /sys/fs/bcache/register #backed device

cryptsetup luksOpen /dev/bcache0 gentoo
Enter password: 

mount /dev/mapper/gentoo /mnt/gentoo
{% endhighlight %}

Отлично, устройство работает, смотрим внутрь:

{% highlight bash %}
ls -l /
...
-rw-r--r--   1 root root    0 апр 28 19:37 ????{
-rw-r--r--   1 root root    0 апр 28 19:37 ?3n?
lrwxrwxrwx   1 root root    5 апр 15 02:23 lib -> lib64/
-rw-r--r--   1 root root    0 апр 28 19:37 l???j????F?s
-rw-r--r--   1 root root    0 апр 28 19:37 L????巴?k6?
...
{% endhighlight %}

Восхитительно. Все признаки того, что fs была попорчена.
Окей, делаем backup самого ценного и скидываем в облако, после чего отмонтируем устройство и прогоняем fsck:

{% highlight bash %}
cd /mnt/gentoo
tar czf /home/kron.tar.gz home/kron etc/
cd /

umount -l /mnt/gentoo
xfs_repair  /dev/bcache0
{% endhighlight %}

Монтируем обратно и смотрим, не исчезли ли файлы:

{% highlight bash %}
mount /dev/bcache0 /mnt/gentoo
ls -l /mnt/gentoo
...
-rw-r--r--   1 root root    0 апр 28 19:37 ????{
-rw-r--r--   1 root root    0 апр 28 19:37 ?3n?
lrwxrwxrwx   1 root root    5 апр 15 02:23 lib -> lib64/
-rw-r--r--   1 root root    0 апр 28 19:37 l???j????F?s
-rw-r--r--   1 root root    0 апр 28 19:37 L????巴?k6?
...
{% endhighlight %}

Неа, не исчезли. И ладно, идем дальше.
Пробуем сделать chroot:

{% highlight bash %}
chroot /mnt/gentoo /bin/bash
error while loading shared libraries: libgcc_s.so.1: cannot open shared object file: no such file or directory
{% endhighlight %}

Ожидаемо. Не знаю, зачем я очень хотел во внутрь, ведь все можно было сделать и снаружи, но меня было не остановить.

{% highlight bash %}
chroot /mnt/gentoo /bin/sh
error while loading shared libraries: libgcc_s.so.1: cannot open shared object file: no such file or directory

chroot /mnt/gentoo /bin/zsh
error while loading shared libraries: libgcc_s.so.1: cannot open shared object file: no such file or directory

chroot /mnt/gentoo ruby
irb(main):001:0>
{% endhighlight %}

О, а это уже не плохо.
Идем дальше:

{% highlight bash %}
chroot /mnt/gentoo python
Python 2.7.10 (default, Dec  3 2015, 18:09:25)
[GCC 4.8.5] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>>
import subprocess
subprocess.check_output(["ls", "/lib/"])

'cpp\ndevice-mapper\ndhcpcd\nfirmware\ngentoo\nld-2.22.so\nld-linux.so.2\nld-linux-x86-64.so.2\nlibacl.so.1\nlibacl.so.1.1.0\nlibaio.so.1\nlibaio.so.1.0.1\nlibanl-2.22.so\nlibanl.so.1\nlibattr.so.1\nlibattr.so.1.1.0\nlibblkid.so.1\nlibblkid.so.1.1.0\nlibBrokenLocale-2.22.so\nlibBrokenLocale.so.1\nlibbz2.so.1\nlibbz2.so.1.0\nlibbz2.so.1.0.6\nlibc-2.22.so\nlibcap.so.2\nlibcap.so.2.24\nlibcidn-2.22.so\nlibcidn.so.1\nlibcom_err.so.2\nlibcom_err.so.2.1\nlibcrack.so.2\nlibcrack.so.2.9.0\nlibcrypt-2.22.so\nlibcrypt.so.1\nlibc.so.6\nlibdevmapper-event-lvm2mirror.so\nlibdevmapper-event-lvm2raid.so\nlibdevmapper-event-lvm2snapshot.so\nlibdevmapper-event-lvm2.so.2.02\nlibdevmapper-event-lvm2thin.so\nlibdevmapper-event.so.1.02\nlibdevmapper.so.1.02\nlibdl-2.22.so\nlibdl.so.2\nlibe2p.so.2\nlibe2p.so.2.3\nlibeinfo.so\nlibeinfo.so.1\nlibext2fs.so.2\nlibext2fs.so.2.4\nlibgcc_s.so.1\nlibhistory.so.6\nlibhistory.so.6.3\nlibip4tc.so.0\nlibip4tc.so.0.1.0\nlibip6tc.so.0\nlibip6tc.so.0.1.0\nlibiptc.so.0\nlibiptc.so.0.0.0\nlibiw.so\nlibiw.so.30\nlibkeyutils.so.1\nlibkeyutils.so.1.5\nlibkmod.so.2\nlibkmod.so.2.2.11\nliblvm2app.so.2.2\nliblvm2cmd.so.2.02\nliblzma.so.5\nliblzma.so.5.2.2\nlibm-2.22.so\nlibmemusage.so\nlibmnl.so.0\nlibmnl.so.0.1.0\nlibmount.so.1\nlibmount.so.1.1.0\nlibm.so.6\nlibmvec-2.22.so\nlibmvec.so.1\nlibncurses.so.5\nlibncurses.so.5.9\nlibncurses.so.6\nlibncurses.so.6.0\nlibncursesw.so.5\nlibncursesw.so.5.9\nlibncursesw.so.6\nlibncursesw.so.6.0\nlibnsl-2.22.so\nlibnsl.so.1\nlibnss_compat-2.22.so\nlibnss_compat.so.2\nlibnss_db-2.22.so\nlibnss_db.so.2\nlibnss_dns-2.22.so\nlibnss_dns.so.2\nlibnss_files-2.22.so\nlibnss_files.so.2\nlibnss_hesiod-2.22.so\nlibnss_hesiod.so.2\nlibnss_nis-2.22.so\nlibnss_nisplus-2.22.so\nlibnss_nisplus.so.2\nlibnss_nis.so.2\nlibpamc.so\nlibpamc.so.0\nlibpamc.so.0.82.1\nlibpam_misc.so\nlibpam_misc.so.0\nlibpam_misc.so.0.82.1\nlibpam.so\nlibpam.so.0\nlibpam.so.0.84.1\nlibpcprofile.so\nlibpcre.so.1\nlibpcre.so.1.2.6\nlibprocps.so.4\nlibprocps.so.4.0.0\nlibpthread-2.22.so\nlibpthread.so.0\nlibrc.so\nlibrc.so.1\nlibreadline.so.6\nlibreadline.so.6.3\nlibresolv-2.22.so\nlibresolv.so.2\nlibrt-2.22.so\nlibrt.so.1\nlibSegFault.so\nlibsmartcols.so.1\nlibsmartcols.so.1.1.0\nlibss.so.2\nlibss.so.2.0\nlibthread_db-1.0.so\nlibthread_db.so.1\nlibudev.so.1\nlibudev.so.1.6.4\nlibusb-0.1.so.4\nlibusb-0.1.so.4.4.4\nlibusb-1.0.so.0\nlibusb-1.0.so.0.1.0\nlibutil-2.22.so\nlibutil.so.1\nlibuuid.so.1\nlibuuid.so.1.3.0\nlibwrap.so.0\nlibwrap.so.0.7.6\nlibxfs.so.0\nlibxfs.so.0.0.0\nlibxlog.so.0\nlibxlog.so.0.0.0\nlibxtables.so.10\nlibxtables.so.10.0.0\nlibz.so.1\nlibz.so.1.2.8\nmodprobe.d\nmodules\nnetifrc\nrc\nsecurity\nsystemd\ntc\nudev\n'
{% endhighlight %}

Не, так не понятно ничего. Поищем, есть ли библиотека вообще:

{% highlight bash %}
find /mnt/gentoo -iname libgcc_s.so.1
/usr/lib64/gcc/x86_64-pc-linux-gnu/4.8.5/libgcc_s.so.1
{% endhighlight %}

О, с этим можно что-то сделать:

{% highlight python %}
import subprocess

lib_orig = "/usr/lib64/gcc/x86_64-pc-linux-gnu/4.8.5/libgcc_s.so.1"
lib_dst = "/lib/libgcc_s.so.1"


print subprocess.check_output(["rm", "-f", lib_dst])
print subprocess.check_output(["ln", "-s", lib_orig, lib_dst])
{% endhighlight %}

Запускаем:

{% highlight bash %}
chroot /mnt/gentoo python /set_lib.py
chroot /mnt/gentoo /bin/bash
~ #>
{% endhighlight %}

О, похоже работает, можно пробовать перезагружаться.
Система действительно загрузилась, а вот иксы нет.

{% highlight bash %}
grep EE /var/log/Xorg.0.log
[    25.504] (EE) AIGLX: reverting to software rendering
[    25.517] (EE) AIGLX error: dlopen of /usr/lib64/dri/swrast_dri.so failed (libstdc++.so.6: cannot open shared object file: No such file or directory)
[    25.517] (EE) GLX: could not load software renderer

{% endhighlight %}

Эта песня хороша, начинай сначала..

{% highlight bash %}
equery b libstdc++.so.6                                                                                                                                          2:40:43
 * Searching for libstdc++.so.6 ...
 sys-devel/gcc-4.8.5 (/usr/lib/gcc/x86_64-pc-linux-gnu/4.8.5/32/libstdc++.so.6 -> libstdc++.so.6.0.20)
 sys-devel/gcc-4.8.5 (/usr/lib/gcc/x86_64-pc-linux-gnu/4.8.5/libstdc++.so.6 -> libstdc++.so.6.0.20)
 sys-devel/gcc-4.9.3 (/usr/lib/gcc/x86_64-pc-linux-gnu/4.9.3/32/libstdc++.so.6 -> libstdc++.so.6.0.20)
 sys-devel/gcc-4.9.3 (/usr/lib/gcc/x86_64-pc-linux-gnu/4.9.3/libstdc++.so.6 -> libstdc++.so.6.0.20)
{% endhighlight %}

Похоже система повисла как раз в тот момент, когда старый gcc уже удалялся, а новый еще не установился. Вот так совпадение.. И именно в тот вечер, когда собираешься лечь по-раньше..
Окей, пересоберем gcc, а пока он будет собираться, напишу эту статью..

{% highlight bash %}
emerge -av1 gcc
{% endhighlight %}

Собирается новый gcc, старый удаляется и вот в момент замены одного gcc на другой (хочу заметить, что замена производится shell скриптом, который зависит от libgcc_s.so.1), все падает, с уже знакомой нам ошибкой:

{% highlight bash %}
error while loading shared libraries: libgcc_s.so.1: cannot open shared object file: no such file or directory
{% endhighlight %}

Где там наш скрипт по установке симлинка?

{% highlight bash %}
python /set_lib.py
{% endhighlight bash %}

Переустанавлиаем профиль gcc вручную.

{% highlight bash %}
gcc-config x86_64-pc-linux-gnu-4.9.3
 * Switching native-compiler to x86_64-pc-linux-gnu-4.9.3 ...
 sh: error while loading shared libraries: libgcc_s.so.1: cannot open shared object file: No such file or directory
 >>> Regenerating /etc/ld.so.cache...
 sh: error while loading shared libraries: libgcc_s.so.1: cannot open shared object file: No such file or directory                                                                        [ ok ]

  * If you intend to use the gcc from the new profile in an already
  * running shell, please remember to do:

  *   . /etc/profile
{% endhighlight %}

Ахаха, что ты делаешь? Прекрати!

{% highlight bash %}
python /set_libs.py
gcc-config -l
 [1] x86_64-pc-linux-gnu-4.9.3 *

{% endhighlight %}

Похоже, на этот раз установилось.
Пробуем запустить Иксы:

{% highlight bash %}
~$ > startx
{% endhighlight %}

И наконец то, все взлетело.
Занавес.
Вот теперь то можно пойти и лечь спать, по-раньше.. В три ночи..

P.S.
Ад на этом не закончился, конечно же. Дальнейшее обновление системы снесло ncurses-5 и заменило его на 6-й. Говорить о том, что вся система была завязана на 5-й и перестала работать, думаю не стоит. Но об этом я уже писать не буду, я же спасть собирался лечь, по-раньше.


