ARG BASE_IMG
FROM ${BASE_IMG}

RUN curl -fsSL https://deb.nodesource.com/setup_15.x | sudo -E bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*
