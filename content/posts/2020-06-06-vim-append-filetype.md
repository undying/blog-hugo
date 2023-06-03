---
title: "VIM: Append Filetype"
date: 2020-06-06 22:47:03 +0300
tags:
- vim
- filetype
---

If you open a file with a non-standard extension, syntax highlighting will not work. This is easily solved by installing filetype manually.

```vim
:set filetype=markdown
```

You can add a hint for VIM about the file type to the file so that you don't have to set the type manually the next time.

```sh
~ cat Readme
# vi:syntax=markdown
```

I wanted to make a hotkey to add information about its type to the end of the file. So I wrote a short function for this and mapped key `<F2>` for it.

```vim
""" insert current filetype at the end of a file
function FileWriteSyntax()
  call append(line('$'), '# vi:syntax=' . &filetype)
endfunction

nnoremap <F2> :call FileWriteSyntax()<CR>
"""
```

Now pressing F2 will append current filetype at the end of the file.

