ARG BASE_IMG=ubuntu:focal
FROM ${BASE_IMG}

ARG USERNAME=user
ARG APT_CACHER_NG_PORT=3142

# setup apt-cacher-ng compatability
COPY config/apt-proxy-detect.sh /etc/apt/
RUN apt-get update && \
    # netcat is used by the above script
    apt-get install -y netcat && \
    rm -rf /var/lib/apt/lists/*

# create user with access to useful groups for development
RUN useradd --create-home -G sudo,dialout ${USERNAME} && \
    \
    # set empty password - sudo just requires 'enter'. Note this gets altered in the release image
    passwd -d ${USERNAME} && \
    \
    # apt-get essentials
    apt-get update && \
    apt-get install -y \
    curl \
    git \
    sudo \
    tumx \
    wget \
    zsh && \
    rm -rf /var/lib/apt/lists/* && \
    \
    # allow optional apt-cache proxy to speed up docker rebuilds the 172 address is THE dockerhost address
    # note this relies on `netcat` which must be installed first and is done just above.
    echo 'Acquire::http { Proxy "/etc/apt/apt-proxy-detect.sh"; };' >> /etc/apt/apt.conf.d/01proxy && \
    \
    # install ohmyzsh
    su ${USERNAME} sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    \
    # install p10k as ohmyzsh plugin
    su ${USERNAME} sh -c "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-/home/${USERNAME}/.oh-my-zsh/custom}/themes/powerlevel10k" && \
    \
    # change default shell for user (leave root so sudo login is obvious)
    echo "auth sufficient pam_rootok.so\n" > /etc/pam.d/chsh && \
    su ${USERNAME} sh -c "chsh -s $(which zsh)"


# makes '${USERNAME}' the default user on login.
ONBUILD USER ${USERNAME}