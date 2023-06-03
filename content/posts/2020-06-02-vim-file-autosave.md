---
title: "VIM: File Autosave"
date: 2020-06-02 00:10:12 +0300
tags:
- vim
- autosave
---

I was wondering how to save file in VIM automatically. Found some solutions in internet but decided to do it my way.
So I wrote this small solution:

```vim
""" Save file on each edit exit
function FileAutoSave()
  if exists('g:file_autosave_async')
    return
  endif

  if @% == ""
    return
  elseif !filewritable(@%)
    return
  endif


  let g:file_autosave_async = 1
  call timer_start(500, 'FileAutoSaveAsync', {'repeat': 1})
endfunction

function FileAutoSaveAsync(timer)
  update
  unlet g:file_autosave_async
endfunction

:autocmd InsertLeave,TextChanged * call FileAutoSave()
"""
```

It updates file in two cases:

- when you leave insert mode
- when text in buffer have been changed

Event "TextChanged" can be triggered too often, that's why I decided to use VIM 8 feature [timer_start()](https://vimhelp.org/eval.txt.html#timer_start%28%29).
After edit event timer will be triggered and file will be saved with delay of 500ms.
This solution will prevent to trigger update too often and will save after every buffer change.

