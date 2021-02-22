ARG BASE_IMG
ARG VERSION=3.10
FROM ${BASE_IMG}

RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python${VERSION} python3-pip && \
    rm -rf /var/lib/apt/lists/*
