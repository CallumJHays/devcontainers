ARG BASE_IMG=ubuntu:focal
FROM ${BASE_IMG}

ARG APT_CACHER_NG_PORT=3142

###############################################################
# APT-CACHER SETUP

COPY config/apt-proxy-detect.sh /etc/apt/
RUN \
    # netcat is needed to run the script
    apt-get update && \
    apt-get install -y netcat && \
    rm -rf /var/lib/apt/lists/* && \
    \
    # make the script executable
    chmod +x /etc/apt/apt-proxy-detect.sh && \
    \
    # note this relies on `netcat` which must be installed first and is done just above.
    echo 'Acquire::http::ProxyAutoDetect "/etc/apt/apt-proxy-detect.sh";\n\
    # passthrough https (dont proxy) - custom deb pkg sources
    Acquire::HTTPS::Proxy "false";\n\
    ' >> /etc/apt/apt.conf.d/30detectproxy

###############################################################
# DEV ENV SETUP

RUN \
    # create user with access to useful groups for development
    useradd --create-home -G sudo,dialout user && \
    \
    # set empty password - sudo just requires 'enter'. Note this gets altered in the release image
    passwd -d user && \
    \
    # apt-get essentials
    apt-get update && \
    apt-get install -y \
    curl \
    git \
    sudo \
    tmux \
    wget \
    zsh && \
    rm -rf /var/lib/apt/lists/* && \
    \
    # install ohmyzsh
    su user sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    \
    # install p10k as ohmyzsh plugin
    su user sh -c "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-/home/user/.oh-my-zsh/custom}/themes/powerlevel10k" && \
    \
    # change default shell for user (leave root so sudo login is obvious)
    echo "auth sufficient pam_shells.so\n" > /etc/pam.d/chsh && \
    su user sh -c "chsh -s $(which zsh)" && \
    \
    # prevent devcontainer folder from being deleted by mistake (hard to recover these)
    mkdir /mnt/workspace && \
    ln -s /mnt/workspace /home/user/workspace

WORKDIR /home/user/workspace
ENTRYPOINT ["zsh", "-c"]
CMD ["zsh"]