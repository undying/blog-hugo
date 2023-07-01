
DATE := $(shell date "+%Y-%m-%dT%H%MZ")

empty :=
space := $(empty) $(empty)

.PHONY: server
server:
	hugo server --buildDrafts

.PHONY: build
build:
	hugo

.PHONY: post
post:
ifeq ($(NAME),)
	hugo new "posts/$(DATE).md"
else
	hugo new "posts/$(DATE)--$(subst $(space),-,$(NAME)).md"
endif

.PHONY: publish
publish:
	git commit -av
	cd public && \
		(cd ../ && git show -s --format='%s') \
		|git commit -aF -
