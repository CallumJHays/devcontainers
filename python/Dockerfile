ARG BASE_IMG
FROM ${BASE_IMG}

ARG VERSION=3.10

RUN add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python${VERSION} python${VERSION}-distutils && \
    rm -rf /var/lib/apt/lists/* && \
    # use python${VERSION} as the default python
    update-alternatives --install /usr/bin/python python /usr/bin/python${VERSION} 10 && \
    curl -sS https://bootstrap.pypa.io/get-pip.py | python
