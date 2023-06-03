---
title: "VIM: YCM and Pipenv"
date: 2020-10-14 23:03:02 +0300
tags:
- vim
- ycm
- pipenv
---

While writing another python script under pipenv I have met a problem that YCM autocomplete worked only for built in functions.
That was annoying because without autocomplete YCM looses it's sense.

## Solution

Let's create module for filetype plugin.

```sh
cat ~/.vim/after/ftplugin/python.vim

if !empty($VIRTUAL_ENV)
  let g:ycm_server_python_interpreter = $VIRTUAL_ENV . '/bin/python'
  let $PYTHONPATH = finddir('site-packages', $VIRTUAL_ENV . '/lib/*')
endif

```

Then you can simply run command

```sh
pipenv run vim some/script.py
```

And now YCM works correctly :3

