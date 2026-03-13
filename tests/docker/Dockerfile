FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates curl git sudo bash unzip gnupg lsb-release wget \
    && rm -rf /var/lib/apt/lists/*

# create non-root user with sudo
RUN useradd -ms /bin/bash tester \
    && echo "tester ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/tester \
    && chmod 0440 /etc/sudoers.d/tester

WORKDIR /home/tester

# copy the workspace into the container
COPY . /home/tester/workspace
RUN chown -R tester:tester /home/tester/workspace

USER tester
WORKDIR /home/tester/workspace

# Make common scripts executable if present
RUN chmod +x install.sh || true

# Run the repository's install script by default (allow failure)
CMD ["bash", "-lc", "./install.sh || true"]
