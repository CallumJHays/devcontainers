ARG BASE_IMG
FROM ${BASE_IMG}

ARG VERSION=3.6

RUN add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update && \
    # uninstall default python that comes with ubuntu
    apt-get purge -y python3.8 && \
    apt-get autoremove -y python3.8 && \
    apt-get install -y python${VERSION} && \
    # distutils is needed for some versions of python (to install pip) but not all
    apt-get install -y  python${VERSION}-distutils || true && \
    rm -rf /var/lib/apt/lists/* && \
    # use python${VERSION} as the default python
    update-alternatives --install /usr/bin/python python /usr/bin/python${VERSION} 10 && \
    curl -sS https://bootstrap.pypa.io/get-pip.py | python
