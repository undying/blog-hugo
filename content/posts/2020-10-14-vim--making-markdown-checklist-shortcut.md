---
title: "VIM: Making Markdown Checklist Shortcut"
date: 2020-10-14 23:45:53 +0300
tags:
- vim
- markdown
- vimscript
---

Interesting exercise to implement shortcut in vim.
Often while writing markdown files in vim I'm writing a lot of checkboxes.
It's a bit annoying to do by hand so let's make a script and bind it to shortcut.

```vimscript
""" markdown shortcuts
function MarkdownCheckboxInsert()
  let l:line = line('.')
  let l:str = getline(l:line)

  let l:match = matchlist(l:str, '^\([ ]*\)\?\([-+*]\)\? \?\(.*\)$')

  if empty(l:match[2])
    let l:list_syn = '-'
  else
    let l:list_syn = l:match[2]
  endif

  let l:buf = l:match[1] . l:list_syn . ' [ ] - ' . l:match[3]
  call setline(l:line, l:buf)
endfunction

nnoremap <Leader>mc :call MarkdownCheckboxInsert()<CR>$
"""
```

Now we can use shortcut `\mc`

- `m` - Markdown
- `c` - checkbox

You can also point to already existing line or list and this will transform your line to checkbox.
