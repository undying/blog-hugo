---
title: "ZSH: auto git config.user"
date: 2020-06-25 22:36:59 +0300
tags:
- zsh
- git
---

On my laptop and desktop I usually have many git repositories. Some of them are personal and some of them are from my main job. In companies it's common practice to have corporate email that used in repository configuration.

```sh
git config user.name "Mr Anderson"
git config user.email "anderson@corp.in"
```

In personal repository you may use some cool nickname and personal email.

```sh
git config user.name "Neo"
git config user.email "0xff@matr.ix"
```

But there is an headache to not forget configure every repository to be corporate or personal after cloning.
I'm using zsh and I have found easy solution for this.

On file system I keep corporate repositories in special folder like `<company>/repos`.
So I decided to make my default configuration to be personal, and change it in corporate repositories on demand.

Zsh have a [hook system](http://zsh.sourceforge.net/Doc/Release/Functions.html). You can create a function and specify in which hook you want to call it. There is a hook named chdir, it's called when you changing your directory.

The algorithm is simple:
- check that current directory is a git repository
- if so, check in which directory it's based
- if it's corporate directory - set corporate email and name

Here is a functions added to .zsrc:

```sh
_git_config_user(){
  case ${PWD} in
    *"mycompany/repos"*)
      git config user.email "denis@mycompany.com"
      git config user.name "Denis Bozhok"
      ;;
    *)
      return 0
  esac
}

__git_cd_functions_set(){
  [[ -d .git ]] || return 0
  _git_config_user
}
chpwd_functions+=( __git_cd_functions_set )
```

Last string appends function `__git_cd_functions_set` to chpwd hooks chain:
```sh
chpwd_functions+=( __git_cd_functions_set )
```

Now any repository placed in directory which path contains `mycompany/repos` will be configured to have corporate name and email.
