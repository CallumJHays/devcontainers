# https://docs.docker.com/engine/examples/apt-cacher-ng/
# Another one I tried on dockerhub was somehow full of issues which I couldn't debug.
# This image works phenomenally though
FROM ubuntu:focal

VOLUME ["/var/cache/apt-cacher-ng"]
RUN    apt-get update && apt-get install -y apt-cacher-ng

EXPOSE 3142
CMD chmod 777 /var/cache/apt-cacher-ng && \
    /etc/init.d/apt-cacher-ng start && \
    tail -f /var/log/apt-cacher-ng/*
