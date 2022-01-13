FROM ubuntu:21.04
LABEL maintainer="Aad Versteden <madnificent@gmail.com>"

# Install nodejs as per http://askubuntu.com/questions/672994/how-to-install-nodejs-4-on-ubuntu-15-04-64-bit-edition
RUN export DEBIAN_FRONTEND=noninteractive; apt-get -y update; apt-get -y install wget python build-essential git libfontconfig curl rsync
RUN wget -qO- https://deb.nodesource.com/setup_16.x > node_setup.sh
RUN bash node_setup.sh
RUN apt-get -y install nodejs
RUN npm install -g npm@7.18.1
# Install bower
RUN npm install -g bower@1.8.12
RUN echo '{ "allow_root": true }' > /root/.bowerrc
# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get -y install yarn
# Install ember-cli
RUN npm install -g ember-cli@3.26.1

WORKDIR /app
