# can change this if another image already has the majority of the deps you want
BASE_IMG = ubuntu:focal

define docker_build
    docker build -t dc_$(1) $(2) $(1)
endef

dc_base: $(wildcard base/*)
	docker build -t dc_base --build-arg BASE_IMG=$(BASE_IMG) base

# catch-all for all other builds
dc_%: dc_base $(wildcard %/**/*)
	$(call docker_build,$*)
