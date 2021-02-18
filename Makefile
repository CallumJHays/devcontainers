.SECONDARY:

# can change this if another image already has the majority of the deps you want
BASE_IMG = ubuntu:focal

# build flag directory
_BF_DIR = .built_flags
DOCKERHUB_USER = callumjhays

# TODO: stack-chaining
PREV_IMG = $(DOCKERHUB_USER)/base-devcontainer

$(_BF_DIR)/base: $(wildcard ./base/* ./base/**/*)
	docker build -t $(DOCKERHUB_USER)/base-devcontainer --build-arg BASE_IMG=$(BASE_IMG) base
	touch $@

# catch-all for all other image builds
$(_BF_DIR)/%: $(_BF_DIR)/base $(wildcard ./%/* ./%/**/*)
	docker build -t $(DOCKERHUB_USER)/$*-devcontainer --build-arg BASE_IMG=$(PREV_IMG) $*
	touch $@

publish-%: %
	docker push $(DOCKERHUB_USER)/$*-devcontainer

%: $(_BF_DIR)/%
	@echo Updating $@... $^