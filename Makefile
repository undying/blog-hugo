
DATE := $(shell date "+%Y-%m-%dT%H%MZ")

empty :=
space := $(empty) $(empty)

.PHONY: server
server:
	hugo server --buildDrafts

.PHONY: post
post:
ifeq ($(NAME),)
	hugo new "posts/$(DATE).md"
else
	hugo new "posts/$(DATE)--$(subst $(space),-,$(NAME)).md"
endif
