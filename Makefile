.SECONDARY:

# CORE_IMG: used to build base-devcontainer
# can change this if another image already has the majority of the deps you want
CORE_IMG = ubuntu:focal

# used to chain images together
BUILD_PREFIX =

# change to your own dockerhub host if you want
DOCKERHUB_USER = callumjhays

# reset by ci-publish-xxx
DOCKER_BUILD = docker build


.built-flags:
	mkdir .built-flags


.built-flags/base: .built-flags $(wildcard ./base/* ./base/**/*)
	docker build \
		-t $(DOCKERHUB_USER)/base-devcontainer \
		--build-arg BASE_IMG=$(CORE_IMG) \
		base
	touch $@


# The secret sauce of this project
# iterate through the target name segments eg "rust-python3.10-node11"
# and build ech image passing the previous in as it's $BASE_IMG
# ie: (base -> rust -> rust-python3.10 -> rust-python3.10-node11)-devcontainer
.built-flags/$(BUILD_PREFIX)%: .built-flags/base $(wildcard ./$(BUILD_PREFIX)%/* ./$(BUILD_PREFIX)%/**/*)
	# if the target includes a "-"
	BUILD_PREFIX=$(BUILD_PREFIX); \
	if echo "$*" | grep -q "-"; then \
		\
		IMG_HEIRARCHY=$$(echo "$*" | tr - " "); \
		\
		for IMG in $${IMG_HEIRARCHY}; do \
			$(MAKE) .built-flags/$${BUILD_PREFIX}$${IMG} BUILD_PREFIX=$${BUILD_PREFIX}; \
			BASE_IMG=$(DOCKERHUB_USER)/$${IMG_CHAIN}-devcontainer; \
			BUILD_PREFIX=$${BUILD_PREFIX}$${IMG}-; \
		done; \
	\
	else \
		$(DOCKER_BUILD) \
			-t $(DOCKERHUB_USER)/$(BUILD_PREFIX)$*-devcontainer \
			--build-arg BASE_IMG=$(DOCKERHUB_USER)/$${BUILD_PREFIX:-base-}devcontainer \
			$*; \
	fi;
	
	touch $@


publish-%: %
	docker push $(DOCKERHUB_USER)/$*-devcontainer


# for use by CI only - takes advantage of build caches but has some other annoying quirks
ci-publish-%:
	docker buildx create --use --name devcontainer-builder || true

	# buildx is hard-coded to retrieve metadata from a registry server.
	# so, sadly the --push flag is necessary
	$(MAKE) $* DOCKER_BUILD="docker buildx build \
		--cache-from "type=local,src=/tmp/.buildx-cache/" \
		--cache-to "type=local,dest=/tmp/.buildx-cache/" \
		--push"


# sometimes "make Makefile" gets sent or something?? this catches that
Makefile:
	@echo

# shorthand niceness
%: .built-flags/%
	@echo