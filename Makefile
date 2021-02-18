.SECONDARY:

# can change this if another image already has the majority of the deps you want
BASE_IMG = ubuntu:focal

# build flag directory
DOCKERHUB_USER = callumjhays

# TODO: stack-chaining
PREV_IMG = $(DOCKERHUB_USER)/base-devcontainer

.built_flags/base: $(wildcard ./base/* ./base/**/*)
	docker build -t $(DOCKERHUB_USER)/base-devcontainer --build-arg BASE_IMG=$(BASE_IMG) base
	touch $@

# catch-all for all other image builds
.built_flags/%: .built_flags/base $(wildcard ./%/* ./%/**/*)
	# TODO: scan "ARG VERSION=" for version tagging, ie: python3.10
	docker build -t $(DOCKERHUB_USER)/$*-devcontainer --build-arg BASE_IMG=$(PREV_IMG) $*
	touch $@

publish-%: %
	docker push $(DOCKERHUB_USER)/$*-devcontainer

%: .built_flags/%
	@echo Updating $@... $^