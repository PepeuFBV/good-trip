FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates curl git sudo bash unzip zip gnupg lsb-release wget zsh \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user with sudo
ARG USERNAME=vscode
RUN useradd -ms /bin/zsh ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

# Put the user-local bin on PATH so it is a real Docker env var and visible
# to both the container environment and devcontainer remoteEnv lookups.
ENV PATH="/home/${USERNAME}/.local/bin:${PATH}"

USER ${USERNAME}
WORKDIR /home/${USERNAME}
