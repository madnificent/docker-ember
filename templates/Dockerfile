FROM ubuntu:22.04
LABEL maintainer="Aad Versteden <madnificent@gmail.com>"

# Install nodejs as per https://github.com/nodesource/distributions#installation-instruction
ARG NODE_MAJOR=20
RUN export DEBIAN_FRONTEND=noninteractive; apt-get -y update; apt-get -y install ca-certificates curl gnupg python3 build-essential git libfontconfig rsync
RUN mkdir -p /etc/apt/keyrings && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" > /etc/apt/sources.list.d/nodesource.list
RUN apt-get -y update && apt-get -y install nodejs

# Enable corepack
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
RUN corepack enable

# Install ember-cli
RUN npm install -g ember-cli@@EMBER_VERSION

WORKDIR /app
