FROM ubuntu:22.04
LABEL maintainer="Aad Versteden <madnificent@gmail.com>"

# Install nodejs as per https://github.com/nodesource/distributions#installation-instruction
ARG NODE_MAJOR=20
RUN echo ${NODE_MAJOR}