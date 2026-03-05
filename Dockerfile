FROM ubuntu:24.04
LABEL maintainer="Aad Versteden <madnificent@gmail.com>"

# Install nodejs as per https://github.com/nodesource/distributions#installation-instruction
ARG NODE_MAJOR=22
RUN export DEBIAN_FRONTEND=noninteractive; apt-get -y update; apt-get -y install ca-certificates curl gnupg python3 build-essential git libfontconfig rsync
RUN mkdir -p /etc/apt/keyrings && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" > /etc/apt/sources.list.d/nodesource.list
RUN apt-get -y update && apt-get -y install nodejs

# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get -y install yarn

# Install ember-cli
RUN npm install -g ember-cli@5.12.0

# Install ember-cli-update
RUN npm install -g ember-cli-update

WORKDIR /app
