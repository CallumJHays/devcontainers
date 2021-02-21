FROM docker:dind

ENV DOCKER_TLS_CERTDIR /certs

# This could probably be replaced by DOCKER_BUILDKIT=true
RUN apk add --update --no-cache curl git jq make && \
    # install docker buildx to the dind env (https://gitlab.com/cmmarslender/docker-buildx/-/blob/master/Dockerfile)
    # so that we can test the explicit build caching in makefile (mainly for use by CI/CD)
    LATEST=$(curl -s https://api.github.com/repos/docker/buildx/releases/latest | jq -r ".tag_name") && \
    curl -sL --output buildx https://github.com/docker/buildx/releases/download/$LATEST/buildx-$LATEST.linux-amd64 && \
    chmod a+x buildx && \
    mkdir -p /root/.docker/cli-plugins/ && \
    mv buildx /root/.docker/cli-plugins/docker-buildx
