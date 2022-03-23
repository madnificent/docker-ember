FROM ubuntu:22.04
LABEL maintainer="Aad Versteden <madnificent@gmail.com>"

# Install nodejs as per http://askubuntu.com/questions/672994/how-to-install-nodejs-4-on-ubuntu-15-04-64-bit-edition
RUN export DEBIAN_FRONTEND=noninteractive; apt-get -y update; apt-get -y install wget python3 build-essential git libfontconfig curl rsync
RUN wget -qO- https://deb.nodesource.com/setup_16.x > node_setup.sh
RUN bash node_setup.sh
RUN apt-get -y install nodejs
RUN npm install -g npm@8.10.0

# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get -y install yarn

# Install ember-cli
RUN npm install -g ember-cli@@EMBER_VERSION

WORKDIR /app

# install chrome for default testem config
RUN \
    apt-get update &&\
    apt-get install -y \
        apt-transport-https \
        gnupg \
        --no-install-recommends &&\
  curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - &&\
  echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list &&\
  apt-get update &&\
  apt-get install -y \
      google-chrome-stable \
      --no-install-recommends

# tweak chrome to run with --no-sandbox option
RUN \
  sed -i 's/"$@"/--no-sandbox "$@"/g' /opt/google/chrome/google-chrome
