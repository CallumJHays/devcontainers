.SECONDARY:

# CORE_IMG: used to build base-devcontainer
# can change this if another image already has the majority of the deps you want
CORE_IMG = ubuntu:focal

# used to chain images together
BUILD_PREFIX =

# change to your own dockerhub host if you want
DOCKERHUB_USER = callumjhays

# buildx for cache that can be saved to fs as build artifact
# speeds up CI builds 
USE_BUILDX = false

.built-flags:
	mkdir .built-flags


.built-flags/base: .built-flags $(wildcard base/* base/**/*)
	DOCKER_BUILD="docker build --pull"; \
	if [ "$${USE_BUILDX}" = "true" ]; then \
		DOCKER_BUILD="docker buildx build \
		--cache-from type=local,src=/tmp/.buildx-cache/base-devcontainer \
		--cache-to type=local,dest=/tmp/.buildx-cache/base-devcontainer \
		--push"; \
	fi; \
	\
	$${DOCKER_BUILD} base  \
		-t $(DOCKERHUB_USER)/base-devcontainer \
		--build-arg BASE_IMG=$(CORE_IMG)
	touch $@


# The secret sauce of this project
# iterate through the target name segments eg "rust-python3.10-node11"
# and build ech image passing the previous in as it's $BASE_IMG
# ie: (base -> rust -> rust-python3.10 -> rust-python3.10-node11)-devcontainer
.built-flags/$(BUILD_PREFIX)%: .built-flags/base $(wildcard $(BUILD_PREFIX)%/* $(BUILD_PREFIX)%/**/*)
	# if the target includes a "-"
	@BUILD_PREFIX=$(BUILD_PREFIX); \
	TARGET=$*; \
	if echo "$*" | grep -q "-"; then \
		\
		IMG_HEIRARCHY=$$(echo "$${TARGET}" | tr - " "); \
		\
		for IMG in $${IMG_HEIRARCHY}; do \
			echo $(MAKE) .built-flags/$${BUILD_PREFIX}$${IMG} BUILD_PREFIX=$${BUILD_PREFIX}; \
			$(MAKE) .built-flags/$${BUILD_PREFIX}$${IMG} BUILD_PREFIX=$${BUILD_PREFIX}; \
			BUILD_PREFIX=$${BUILD_PREFIX}$${IMG}-; \
		done; \
	\
	else \
		DOCKER_BUILD="docker build --pull"; \
		if [ "$${USE_BUILDX}" = "true" ]; then \
			DOCKER_BUILD="docker buildx build \
			--cache-from type=local,src=/tmp/.buildx-cache/$${BUILD_PREFIX}$${TARGET}-devcontainer \
			--cache-to type=local,dest=/tmp/.buildx-cache/$${BUILD_PREFIX}$${TARGET}-devcontainer \
			--push"; \
		fi; \
		\
		echo $${DOCKER_BUILD} $${TARGET} \
			-t $(DOCKERHUB_USER)/$(BUILD_PREFIX)$${TARGET}-devcontainer \
			--build-arg BASE_IMG=$(DOCKERHUB_USER)/$${BUILD_PREFIX:-base-}devcontainer; \
		\
		$${DOCKER_BUILD} $${TARGET} \
			-t $(DOCKERHUB_USER)/$(BUILD_PREFIX)$${TARGET}-devcontainer \
			--build-arg BASE_IMG=$(DOCKERHUB_USER)/$${BUILD_PREFIX:-base-}devcontainer; \
	fi;
	
	touch $@


publish-%: %
	docker login
	docker push $(DOCKERHUB_USER)/$*-devcontainer


# for use by CI only - takes advantage of build caches but has some other annoying quirks
ci-publish-%:
	docker login
	docker buildx create --use --name devcontainer-builder || true

	# buildx is hard-coded to retrieve metadata from a registry server.
	# so, sadly the --push flag is necessary
	$(MAKE) $* USE_BUILDX=true

	@echo "=============================="
	@echo "ci-publish-$*: BUILD SUCCEEDED"


# sometimes "make Makefile" gets sent or something?? this catches that
Makefile:
	@echo

# shorthand niceness
%: .built-flags/%
	@echo updating $*