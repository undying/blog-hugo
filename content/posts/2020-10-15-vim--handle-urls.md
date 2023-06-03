---
title: "VIM: Handle Urls"
date: 2020-10-15 22:32:39 +0300
tags:
- vim
- url
- http
---

# Making a shortcut to open urls under cursor

**Note**: *There is also available `gx` shortcut that uses netrw plugin.
But I've decided to use own little solution instead of big plugin for one function.*

```vimscript
""" open urls using \u shortcut
function HandleURL()
  let l:uri = matchstr(getline("."), '[a-z]*:\/\/[^ >,;)]*')
  if l:uri != ""
    silent call system("xdg-open " . shellescape(l:uri, 1))
  else
    echo "No URI found in line."
  endif
endfunction

nnoremap <leader>u :call HandleURL()<cr>
"""
```

Now if we hit `\u` shortcut while our cursor is on the url line, this url will be opened in default browser.
You may like to change xdg-open to any other program you need.

